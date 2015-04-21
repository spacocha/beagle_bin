#! /usr/bin/perl
#
#

	die "Usage: list mockhit unique.ab.fa > redirect\n" unless (@ARGV);
	($list, $file1, $trans) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
chomp ($list);
chomp ($trans);
$verbose=1;
$/=">";
open (IN1, "<$trans") or die "Can't open $trans\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($name, @unique)=split ("\n", $line1);
    ($id, $abund)=$name=~/^(.+)\/ab=([0-9]+)\//;
    $uniquehash{$id}++;
    $abhash{$id}=$abund;
}
close (IN1);

$/="\n";
open (IN1, "<$file1") or die "Can't open $file1\n";
while ($line1=<IN1>){
    chomp ($line);
    next unless ($line1);
    ($unique, $mocks, $percent, $total, $mis, $gap, $start, $end)=split ("\t", $line1);
    ($span)=$end-$start+1;
    ($mock)=$mocks=~/^(.+)_[0-9]+_[0-9]+_[0-9]+/;
    if ($span>186){
	if ($percent > 95){
	    print "allids $unique\n" if ($verbose);
	    $allids{$unique}++;
	    $besthash{$unique}{$mock}++;
	}
    }
}
close (IN1);

open (IN, "<$list") or die "Can't open $list\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($id, @pieces)=split ("\t",$line);
    foreach $seq (@pieces){
	$otuhash{$seq}=$id;
	print "otuhash\t$seq\t$id\n" if ($verbose);
    }
}
close (IN);
foreach $id (sort keys %allids){
    print "Working on this $id\n" if ($verbose);
    foreach $oid (sort keys %allids){
	print "Other id $oid\n" if ($verbose);
	next if ($id eq $oid);
	$addval=$abhash{$id}*$abhash{$oid};
	if (%{$besthash{$id}} && %{$besthash{$oid}}){
	    #both have best blast hit, so consider in the analysis
	    if ($otuhash{$id} && $otuhash{$oid}){
		#both have otu info so consider in analysis
		if ($otuhash{$id} eq $otuhash{$oid}){
		    #they are in the same otu
		    $gotaTP=();
		    foreach $mock (keys %{$besthash{$id}}){
			if ($besthash{$oid}{$mock}){
			    unless ($gotaTP){
				print "I'm a TP $id $oid\n" if ($verbose);
				$TP+=$addval;
				$gotaTP++;
			    }
			}
		    }
		    unless ($gotaTP){
			print "I'm a FP $id\t$oid\n" if ($verbose);
			#it is a true positive
			#it's a false positive
			$FP+=$addval;
		    }
		} else {
		    $gotaFN=();
                    foreach $mock (keys %{$besthash{$id}}){
			if ($besthash{$oid}{$mock}){
                            unless ($gotaFN){
				print "I'm a FN $id $oid\n" if ($verbose);
                                $FN+=$addval;
                                $gotaFN++;
                            }
                        }
                    }
		    unless ($gotaFN){
			#they are in the same OTU but are different mock
			#false positive
			print "I'm a TN $id\t$oid\n" if ($verbose);
			$TN+=$addval;
		    }
		}
	    } else {
		$FN+=$addval;
	    }
	}
    }
}

print "TP\t$TP
FP\t$FP
TN\t$TN
FN\t$FN\n";
