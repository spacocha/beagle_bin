#! /usr/bin/perl
#
#

	die "Usage: list list_type best_blast frac (default 0.95) percent (default 95)\n" unless (@ARGV);
	($list, $type, $file1, $fracval, $percentval) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
chomp ($list);
chomp ($type);
chomp ($fracval);
chomp ($percentval);
$fracval =0.95 unless ($fracval);
$percentval = 95 unless ($percentval);

open (IN1, "<$file1") or die "Can't open $file1\n";
while ($line1=<IN1>){
    chomp ($line);
    next unless ($line1);
    ($s, $q, $percent, $len, $mis, $gap, $sstart, $send, $qstart, $qend, $evalue, $bits)=split ("\t", $line1);
    ($coverage)=$qend-$qstart+1;
    $frac=$coverage/76;
    if ($s=~/\/ab=[0-9]+\//){
	($news)=$s=~/^(.+)\/ab=[0-9]+\//;
    } else {
	$news=$s;
    }
    if ($frac >= $fracval && $percent >= $percentval){
	#only record the values that are above the threshold
	$hash{$news}=$q;
	$allids{$news}++;
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
	if ($hash{$id} && $hash{$oid}){
	    #both have best blast hit, so consider in the analysis
	    if ($otuhash{$id} && $otuhash{$oid}){
		#both have otu info so consider in analysis
		if ($otuhash{$id} eq $otuhash{$oid}){
		    #they are in the same otu
		    if ($hash{$id} eq $hash{$oid}){
			#they map to the same mock and in the same OTU
			#this is a true positive
			$TP++;
		    } else {
			#they are in the same OTU but are different mock
			#false positive
			$FP++;
		    }
		} else {
		    if ($hash{$id} eq $hash{$oid}){
			#they are not in the same OTU but match the same mock
			#this is a false negative
			$FN++;
		    } else {
			#they do not match the same mock and are not the same OTU
			#this is a true negative
			$TN++;
		    }
		}
	    } else {
		#false neg because the pair is not clustered
		$FN++;
	    }
	}
    }
}

print "TP\t$TP
FP\t$FP
TN\t$TN
FN\t$FN\n";
