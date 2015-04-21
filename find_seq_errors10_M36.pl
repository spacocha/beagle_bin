#! /usr/bin/perl -w
#
#

	die "Usage: bp_freq_file align_fa qual_file stdv_file mock_fa old_stats> Redirect\n" unless (@ARGV);
	($bpfreq, $align, $qual, $stdev, $mock, $oldstats) = (@ARGV);

	die "Please follow command line args\n" unless ($mock);
chomp ($bpfreq);
chomp ($align);
chomp ($qual);
chomp ($stdev);
chomp ($mock);
chomp ($oldstats) if ($oldstats);


#record library distribution data

open (IN, "<$mock" ) or die "Can't open $mock\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, $seq) =split ("\t", $line);
    $mockhash{$OTU}=$seq;
      
}
close (IN);
$/="\n";
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
	if ($line=~/^(.+): Done testing as parent/){
	    ($childtest)=$line=~/^(.+): Done testing as parent/;
	    $skiphash{$childtest}++;
	} elsif ($line=~/^Changefrom,.+Done$/){
	    ($childtest, $parent)=$line=~/^Changefrom,(.+?),(ID[0-9]+P),Changeto/;
	    $skiphash2{$parent}{$childtest}++;
	} elsif ($line=~/Change.+Alignment mistake/){
	    ($childtest, $parent)=$line=~/^Change (.+?) => (ID[0-9]+P)/;
	    $skiphash2{$parent}{$childtest}++;
	}
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

#Do alignment mistakes first
foreach $id (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
    #only evaluate things that are at lower abundances than oid and not already changed to a higher thing
    foreach $oid (sort keys %mockhash){
	next if ($childalignhash{$id} || $skiphash2{$oid}{$id});
	#check to see if the alignment is the only thing that is different between these sequences
#make a gapless sequence                                                                                                                                               
	$gapless1=$seqhash{$id};
	$gapless2=$mockhash{$oid};
	$gapless1=~s/-//g;
	$gapless2=~s/-//g;
	#check if the alignment is the only difference
	if ($gapless1 eq $gapless2){
	    print "${id}\t${oid}\tAlignment mistake\n";
	    $childalignhash{$id}++;
	    next;
	}
    }
}

foreach $id (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
    next if ($childalignhash{$id});
    foreach $oid (sort keys %mockhash){
	#only evaluate things that are at lower abundances than oid and not already changed to a higher thing
	next if ($skiphash2{$oid}{$id});
	#next see how many difference between the two seqeunces
	%keepqual=();
	%keepfreq=();
	$seq=$seqhash{$id};
	$oseq=$mockhash{$oid};
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
	if (@mismatch){
	    $mismatches=@mismatch;
	} else {
	    $mismatches=0;
	    print "${id}\t${oid}\tIdentical\n";
            $childalignhash{$id}++;
            last;
	}
	%warning=();
	$mismatchidoid{$id}{$oid}=$mismatches;
	foreach $i (@mismatch){
	    $base=$bases[$i];
	    $obase = $obases[$i];
	    $freq=$bpfreqhash{$i}{$base};
	    $ofreq=$bpfreqhash{$i}{$obase};
	    if ($freq*2 >=$ofreq){
		$warning{$i}{"freq"}="BAD: ID base $i $base is more frequent ($freq) than ODI ($ofreq)";
	    } else {
		$warning{$i}{"freq"}="GOOD: ID base $i $base is less frequent ($freq) than OID ($ofreq)";
		$keepfreq{$id}{$oid}++;
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
	if (@mismatch){
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
			    $keepqual{$id}{$oid}++;
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
			    $keepqual{$id}{$oid}++;
			} else {
			    $warning{$i}{"qual"}="BAD: This base is not lower quality $i $bqual => $quals[$i] <= $aqual";
			}
		    }
		} else {
		    $warning{$i}{"qual"}="GOOD: This base is a gap $i";
		    $keepqual{$id}{$oid}++;
		}
	    }
	}
    }
}

foreach $id (sort keys %abundhash){
    foreach $oid (sort {$a <=> $b} keys %{$mismatchidoid{$id}}){
	#choose the one with the fewest mismatches
	print "$id\t$oid\t$mismatchidoid\t$keepfreq{$id}{$oid}\t$keepqual{$id}{$oid}\n";
	last;
    }
}
	
print "Finished\n";

sub chisqtest {
    #get the sum of all bars for OTU1
    $OTU1sum=0;
    foreach $bar (sort keys %{$mathash{$OTU1}}){
	$OTU1sum+=$mathash{$OTU1}{$bar};
    }
    #test against all other OTUs in the dataset
    $OTU2sum=0;
    foreach $bar (sort keys %{$mathash{$OTU2}}){
	$OTU2sum+=$mathash{$OTU2}{$bar};
    }
    $OTUsum=$OTU1sum+$OTU2sum;
    #get the sum of each library
    %barhash=();
    $bartotal = 0;
    $barcount=0;
    foreach $bar (sort keys %{$mathash{$OTU1}}){
	$barhash{$bar}=$mathash{$OTU1}{$bar}+$mathash{$OTU2}{$bar};
	$bartotal+=$mathash{$OTU1}{$bar};
	$bartotal+=$mathash{$OTU2}{$bar};
	$barcount++ if ($mathash{$OTU1}{$bar} || $mathash{$OTU2}{$bar});
    }
    $df=$barcount-1;
    #OTU total should equal bar total or there's a problem
    die "OTU $OTUsum Bar $bartotal\n" unless ($bartotal==$OTUsum);
    #what is the expected count for each entry
    $chisq = 0;
    foreach $bar (sort keys %{$mathash{$OTU1}}){
	$OTU1frac=$OTU1sum/$OTUsum;
	$OTU2frac=$OTU2sum/$OTUsum;
	$barfrac = $barhash{$bar}/$bartotal;
	$expected1=$OTUsum*$OTU1frac*$barfrac;
	$expected2=$OTUsum*$OTU2frac*$barfrac;
	if ($expected1){
	    $value1 = (($mathash{$OTU1}{$bar} - $expected1)**2)/$expected1;
	    $chisq+=$value1;
	} elsif ($mathash{$OTU1}{$bar}) {
	        die "There's a problem because I have an observed but no expected\n"
		    ;
	    }
	if ($expected2){
	    $value2 = (($mathash{$OTU2}{$bar} - $expected2)**2)/$expected2;
	    $chisq+=$value2;
	} elsif ($mathash{$OTU2}{$bar}) {
	        die "There's a problem because I have an observed but no expected\n"
		    ;
	    }
    }
    $newchisq=$chisq;
    return ($newchisq);
    $chisq=0;
    
}

sub makepvaluehash {
    #pvalues from pg 655 of Applied Statistics and Probability for Engineers Montgomery and Runger
    # p = 0.005
    %pvaluehash = (
		   1 => '7.88',
		   2 => '10.60',
		   3 => '12.84',
		   4 => '14.86',
		   5 => '16.75',
		   6 => '18.55',
		   7 => '20.28',
		   8 => '21.96',
		   9 => '23.59',
		   10 => '25.19',
		   11 => '26.76',
		   12 => '28.30',
		   13 => '29.82',
		   14 => '31.32',
		   15 => '32.80',
		   16 => '34.27',
		   17 => '35.72',
		   18 => '37.16',
		   19 => '38.58',
		   20 => '40.00',
		   21 => '41.40',
		   22 => '42.80',
		   23 => '44.18',
		   24 => '45.56',
		   25 => '46.93',
		   26 => '48.29',
		   27 => '49.65',
		   28 => '50.99',
		   29 => '52.34',
		   30 => '53.67',
		   40 => '66.77',
		   50 => '79.49',
		   60 => '91.95',
		   70 => '104.22',
		   80 => '116.32',
		   90 => '128.30',
		   100 => '140.17',
		   );
}
