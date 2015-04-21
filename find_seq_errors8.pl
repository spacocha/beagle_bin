#! /usr/bin/perl -w
#
#

	die "Use this program to fix errors in sequencing data
It will map low abundance sequences to higher abundance sequences with the following conditions:
Either lower frequency of the mismatched base or lower quality of the mismatched base
Up to three mismatches to a sequence at least 2 x more abundant than it
Usage: bp_freq_file align_fa qual_file stdv_file old_stats> Redirect\n" unless (@ARGV);
	($bpfreq, $align, $qual, $stdev, $oldstats) = (@ARGV);

	die "Please follow command line args\n" unless ($stdev);
chomp ($bpfreq);
chomp ($align);
chomp ($qual);
chomp ($stdev);
chomp ($oldstats) if ($oldstats);

#read in bp freqs for each position
$first=1;
    open (IN, "<${bpfreq}") or die "Can't open BP ${bpfreq}\n";
    while ($line = <IN>){
	chomp ($line);
	next unless ($line);
	($position, @bases) = split ("\t", $line);
	#record position and base information for all of the sequences
	if ($first){
	    (@headers)=@bases;
	    $first=();
	} else {
	    $i=0;
	    $j=@bases;
	    until ($i >=$j){
		$bpfreqhash{$position}{$headers[$i]}=$bases[$i];
		$i++;
	    }
	}
    }
close (IN);
if ($oldstats){
    open (IN, "<${oldstats}") or die "Can't open OLDSTATS ${oldstats}\n";
    while ($line = <IN>){
	chomp ($line);
	next unless ($line);
	next unless ($line=~/^(.+): Done testing as parent/);
	($childtest)=$line=~/^(.+): Done testing as parent/;
	$skiphash{$childtest}++;
	
    }
    close (IN);
}

$/=">";
open (INFA, "<${align}") or die "Can't open ALIGN ${align}\n";
#evaluate each sequence compared to the polyhashfreq
$first=1;
while ($faline=<INFA>){
    chomp ($faline);
    if ($first){
	$first=();
    } else {
	($id, $seq)=split ("\n", $faline);
	$seqhash{$id}=$seq;
    }
}
close (INFA);

open (INQUAL, "<${qual}") or die "Can't open QUAL ${qual}\n";
open (INSTDEV, "<${stdev}") or die "Can't open STDEV ${stdev}\n";
#evaluate each sequence compared to the polyhashfreq
$first=1;
while ($qualine=<INQUAL>){
    $stdevline=<INSTDEV>;
    chomp ($qualine);
    chomp ($stdevline);
    if ($first){
	$first=();
    } else {
	($idplus1, $qual)=split ("\n", $qualine);
	($idplus2, $stdev)=split ("\n", $stdevline);
	($id1, $abund)=$idplus1=~/^(ID[0-9]+P)_([0-9]+)$/;
	($id2, $abund)=$idplus2=~/^(ID[0-9]+P)_([0-9]+)$/;
	die "Not the same files $id1 $id2\n" unless ($id1 eq $id2);
	if ($seqhash{$id1}){
	    $abundhash{$id1}=$abund;
	    $qualhash{$id1}=$qual;
	    $stdevhash{$id1}=$stdev;

	}
    }
}
close (INQUAL);
close (INSTDEV);

foreach $oid (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
    #don't evaluate as a parent if it's already a child
    next if ($childhash{$oid});
    #don't evaluate things that were already checked in previous run
    next if ($skiphash{$oid});
    foreach $id (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
	#only evaluate things that are at lower abundances than oid and not already changed to a higher thing
	next if ($id eq $oid || $abundhash{$id} >= $abundhash{$oid} || $childhash{$id});
	#check to see if the alignment is the only thing that is different between these sequences
	#make a gapless sequence
	$gapless1=$seqhash{$id};
	$gapless2=$seqhash{$oid};
        $gapless1=~s/-//g;
        $gapless2=~s/-//g;
	#check if the alignment is the only difference
	if ($gapless1 eq $gapless2){
	    print "Change $id => $oid\t$id $oid: Alignment mistake\n";
	    $childhash{$id}++;
	    $parenthash{$oid}++;
	    next;
	}
	#next see how many difference between the two seqeunces
	%keepqual=();
	%keepfreq=();
	$seq=$seqhash{$id};
	$oseq=$seqhash{$oid};
	(@bases)=split ("", $seq);
	(@obases)=split ("", $oseq);
	$j=@bases;
	$k=@obases;
	#alignments might be different?
	if ($k<$j){
	    $l=$k;
	} else {
	    $l=$j;
	}
	$i=0;
	@mismatch=();
	until ($i >=$l){
	    die "Bases[$i] $bases[$i] Obases[$i] $obases[$i]\nSeq $seq\nOseq $oseq\n" unless ($bases[$i] && $obases[$i]);
	    unless ($bases[$i] eq $obases[$i]){
		push (@mismatch, $i);
	    }
	    $i++;
	}
	#how many bases are not identical
	$mismatches=@mismatch;
	%warning=();
	if ($mismatches <=3){
	    #these sequences are close (less than 3 mismatches)
	    #see if there is a chance that the mismatch is due to seq error
	    #what is the frequency of mismatch bases
	    foreach $i (@mismatch){
		$base=$bases[$i];
		$obase = $obases[$i];
		$freq=$bpfreqhash{$i}{$base};
		$ofreq=$bpfreqhash{$i}{$obase};
		if ($freq*2 >=$ofreq){
		    $warning{$i}{"freq"}="BAD: ID base $i $base is more frequent ($freq) than ODI ($ofreq)";
		} else {
		    $warning{$i}{"freq"}="GOOD: ID base $i $base is less frequent ($freq) than OID ($ofreq)";
		    $keepfreq{$i}++;
		}
	    }
	    #what is the difference in quality of each potentially wrong base
	    $qual=$qualhash{$id};
	    $stdev=$stdevhash{$id};
	    (@quals)=split ("\t", $qual);
	    (@stdevs)=split ("\t", $stdev);
	    $l=@quals;
	    $stdsum=0;
	    $stdtotal=0;
	    foreach $std (@stdevs){
		next unless ($std=~/[0-9]/);
		if ($stdsum){
		    $stdsum+=$std;
		} else {
		    $stdsum=$std;
		}
		$stdtotal++;
	    }
	    $avestd=$stdsum/$stdtotal if ($stdtotal);

	    foreach $i (@mismatch){
		if ($quals[$i]=~/[0-9]/){
		    $bi=$i-1;
		    $ai=$i+1;
		    if ($bi > -1){
			$foundb=();
			until ($foundb){
			    if ($quals[$bi]=~/[0-9]/){
				$bqual=$quals[$bi];
				$foundb=1;
			    } else {
				$bi-=1;
			    }
			}
		    }
		    if ($ai < $j){
			$founda=();
			until ($founda){
			    if ($quals[$ai]=~/[0-9]/){
				$aqual=$quals[$ai];
				$founda=1;
			    } else {
				$ai+=1;
			    }
			}
		    }
		    if ($abundhash{$id}==1){
			if ($bqual > $quals[$i] && $aqual > $quals[$i]){
			    $warning{$i}{"qual"}="GOOD: This base has lower quality $i $bqual => $quals[$i] <= $aqual";
			    $keepqual{$i}++;
			} else {
			    $warning{$i}{"qual"}="BAD: This base is not lower quality $i $bqual => $quals[$i] <= $aqual";
			}
		    } else {
			$difsum=0;
			$diftotal=0;
			if ($bqual){
			    $difsum+=($bqual-$quals[$i]);
			    $diftotal++;
			}
			if ($aqual){
			    $difsum+=($aqual-$quals[$i]);
			    $diftotal++;
			}
			$aved=$difsum/$diftotal;
			if ($aved*10 > $avestd){
			    $warning{$i}{"qual"}="GOOD: This base has lower quality $i $bqual => $quals[$i] <= $aqual";
			    $keepqual{$i}++;
			} else {
			    $warning{$i}{"qual"}="BAD: This base is not lower quality $i $bqual => $quals[$i] <= $aqual";
			}
		    }
		} else {
		    $warning{$i}{"qual"}="GOOD: This base is a gap $i\n";
		    $keepqual{$i}++;
		}
	    }
	    $throw=0;
	    foreach $i (sort {$a <=> $b} keys %warning){
		$throw=1 unless ($keepqual{$i} || $keepfreq{$i});
		#foreach $val (sort keys %{$warning{$i}}){
		 #   print "$id $oid: $warning{$i}{$val}\n";
		    #foreach value, keep if either the freq or qual suggests it's wrong
		#}
	    }
	    unless ($throw){
		print "Change $id => $oid\t";
		#when it's assigned as a parent, don't evalualte as a child
		$parenthash{$oid}++;
		#when it's assigned as a child, don't evaluate as a parent
		$childhash{$id}++;
		foreach $i (sort {$a <=> $b} keys %warning){
		    foreach $val (sort keys %{$warning{$i}}){
			print "$id $oid: $warning{$i}{$val}\t";
		    }
		}
		print "\n";
	    }
	}
    }
    print "$oid: Done testing as parent\n";
}

 
print "Finished\n";
