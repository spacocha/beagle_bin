#! /usr/bin/perl
#
#

	die "Usage: fasta list list_type dist_file\n" unless (@ARGV);
	($fasta, $list, $type, $file1) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
chomp ($list);
chomp ($type);
chomp ($fasta);

$/=">";
open (IN1, "<$fasta") or die "Can't open $fasta\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($name, $distance)=split ("\n", $line1);
    next if ($name eq ">");
    if ($name=~/^(.+)\/ab=[0-9]+\//){
	($newname, $ab)=$name=~/^(.+)\/ab=([0-9]+)\//;
    } else {
	$newname=$name;
	$ab=1;
    }
    if ($newname && $ab){
	$allids{$newname}++;
	$abhash{$newname}=$ab;
    }

}
close (IN1);

$/="\n";
open (IN1, "<$file1") or die "Can't open $file1\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($s, $q, $distance)=split (" ", $line1);
    if ($s=~/\/ab=[0-9]+\//){
	($news, $ab)=$s=~/^(.+)\/ab=([0-9]+)\//;
    } else {
	$news=$s;
    }
    if ($q=~/\/ab=[0-9]+\//){
        ($newq, $ab)=$q=~/^(.+)\/ab=([0-9]+)\//;
    } else {
        $newq=$q;
    }
    #only record the values that are above the threshold
    if ($distance <= 0.03){
	$disthash{$news}{$newq}++;
    }
}
close (IN1);


open (IN, "<$list") or die "Can't open $list\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    if ($type=~/[Ee]co/){
	(@pieces)=split ("\t", $line);
	($id)=$pieces[0];
    } elsif ($type=~/[Pp]hylo/){
	($id, @pieces)=split ("\t",$line);
    } else {
	die "Don't recognize type (eco or phylo)\n";
    }
    foreach $seq (@pieces){
	if ($seq=~/^.+\/ab=[0-9]+\//){
	    ($newseq)=$seq=~/^(.+)\/ab=[0-9]+\//;
	} else {
	    $newseq=$seq;
	}
	$otuhash{$newseq}=$id;
    }
}

foreach $id (sort keys %allids){
    foreach $oid (sort keys %allids){
	next if ($id eq $oid);
	next if ($done{$id}{$oid});
	$done{$id}{$oid}++;
	$done{$oid}{$id}++;
	$addval=$abhash{$id}*$abhash{$oid};
	if ($disthash{$id}{$oid} || $disthash{$oid}{$id}){
	    #the distance is equal to or less than 0.03
	    if ($otuhash{$id} && $otuhash{$oid}){
		#both have otu info so consider in analysis
		if ($otuhash{$id} eq $otuhash{$oid}){
		    #they are in the same otu and within the cut-off
		    $TP+=$addval;
		} else {
		    #they are within the cut-off but in different OTUs
		    #false positive
		    $FN+=$addval;
		}
	    } else {
		#one is missing an OTU so make it a false negative
		$FN+=$addval;
	    }    
	} else {
	    #they are outside of the distance range
	    if ($otuhash{$id} && $otuhash{$oid}){
                #both have otu info so consider in analysis
		if ($otuhash{$id} eq $otuhash{$oid}){
                    #they are in same otu and outside the cut-off
                    $FP+=$addval;
                } else {
                    $TN+=$addval;
                }
            } else {
		#one wasn;t clustered
		$FN+=$addval;
            }
	}
    }
}


print "TP\t$TP
FP\t$FP
TN\t$TN
FN\t$FN\n";
