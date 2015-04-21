#! /usr/bin/perl -w
#
#

	die "Use this program to fix errors in sequencing data
It will map low abundance sequences to higher abundance sequences with the following conditions:
Either lower frequency of the mismatched base or lower quality of the mismatched base
Up to three mismatches to a sequence at least 2 x more abundant than it
Usage: bp_freq_file align_fa qual_file stdv_file mat_file old_stats> Redirect\n" unless (@ARGV);
	($bpfreq, $align, $qual, $stdev, $matfile, $oldstats) = (@ARGV);

	die "Please follow command line args\n" unless ($matfile);
chomp ($bpfreq);
chomp ($align);
chomp ($qual);
chomp ($stdev);
chomp ($matfile);
chomp ($oldstats) if ($oldstats);

use Statistics::R;

#record library distribution data
$first=1;
open (IN, "<$matfile" ) or die "Can't open $matfile\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @libs) =split ("\t", $line);
    if ($first){
	$first=();
	(@headers)=@libs;
    } else {
	$i=0;
	$j=@headers;
	until ($i>$j){
	    $mathash{$OTU}{$headers[$i]}=$libs[$i] if ($headers[$i]);
	    $matbarhash{$headers[$i]}++ if ($headers[$i]);
	    $i++;
	}
    }
      
}
close (IN);

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
	} elsif ($line=~/^Change .+ => .+ /){
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

$R = Statistics::R->new() ;
$R->startR ;
makepvaluehash();

foreach $oid (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
    #don't evaluate as a parent if it's already a child
    next if ($childhash{$oid});
    #don't evaluate things that were already checked in previous run
    next if ($skiphash{$oid});
    foreach $id (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
	#only evaluate things that are at lower abundances than oid and not already changed to a higher thing
	next if ($id eq $oid || $abundhash{$id} >= $abundhash{$oid} || $childhash{$id} || $skiphash2{$oid}{$id});
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
		#check if the distributions are the same across libraries
		$totalnolib=0;
		$string=();
		$change=0;
		$pvalue=();
		
		foreach $bar (sort keys %matbarhash){
		    #don't print, but pass something to R
		    $mathash{$oid}{$bar} = 0 unless ($mathash{$oid}{$bar});
		    $mathash{$id}{$bar} =0 unless ($mathash{$id}{$bar});
		    if ($mathash{$oid}{$bar} || $mathash{$id}{$bar}){
			if ($string){
			    $string="$string,"."$mathash{$oid}{$bar},$mathash{$id}{$bar}";
			} else {
			    $string="$mathash{$oid}{$bar},$mathash{$id}{$bar}";
			}
			$totalnolib++ if ($mathash{$oid}{$bar} || $mathash{$id}{$bar});
		    }
		}
		if ($totalnolib ==1){
		    #if they are both only found in one library, combine them
		    $pvalue=1;
		    $change++;
		} else {
		    #run chisq and fishers
#		    $R->send(q`alleles <- matrix(c($string), nr=2)`) ;
#		    $R->send(qq`print(alleles)`) ;
		    $R->send(qq`alleles<-matrix(c($string),nr=2)`);
		    $R->send(q`x<-t(alleles)`);
		    #first try fishers test
		    $R->send(qq`h<-fisher.test(x)`);
		    $R->send(q`print(h$p.value)`);
		    $ret = $R->read ;
		    if ($ret=~/^[1] [0-9]/){
			#you got a pvalue from fishers test
			($fpvalue)=$ret=~/^[1] ([0-9].+)$/;
			if ($fpvalue>0.005){
			    $change++;
			    $pvalue="Fish: $fpvalue";
			}
		    } else {
			#run chisq 
			#if 80% of the values are above 5, then pvalue is ok
			#if not, you might get significant pvalues when it's not supposed to be
			#then merge if the correlations are ok
			#try chisq with R
			$R->send(qq`i<-chisq.test(x)`);
			$R->send(q`print(i$p.value)`);
			$ret2 = $R->read ;
                        if ($ret2=~/\[[0-9]/){
                            ($cpvalue) = $ret2=~/\[[0-9].*\] (.+)$/;
                        }
			#also get chisq manually
			$OTU1=$oid;
			$OTU2=$id;
			#otherwise do a manual chisq test with OTU1 and OTU2 and mathash above                                                                                       
			($chisq)=chisqtest();
			if ($df > 0){
			    if ($df > 100){
				die "Too many degrees of freedom $df\n";
			    } elsif ($pvaluehash{$df}){
				$df= $df;
			    }elsif ($df> 90 && $df<99){
				$df=100;
			    } elsif ($df > 80 && $df < 89){
				$df=90;
			    } elsif ($df > 70 && $df < 79){
				$df=80;
			    } elsif ($df > 60 && $df < 69){
				$df=70;
			    } elsif ($df > 50 && $df < 59){
				$df=60;
			    } elsif ($df > 40 && $df < 49){
				$df=50;
			    }elsif ($df > 30 && $df < 39){
				$df=40;
			    }
			    $critvalue=$pvaluehash{$df};
			    if ($critvalue < $chisq){
				$manpvalue=0.004;
			    } else {
				$manpvalue=0.006;
			    }
			} else {
			    $manpvalue=1;
			}
			#are either pvalues reasonable
			$R->send(q`print(i$expected)`);
			$ret3 = $R->read ;
			@retpie=();
			(@retpie)=split ("\n", $ret3);
			$hightot=0;
			$exptot=0;
			$expercent=0;
			foreach $pie (@retpie){
			    $pie2=$pie;
			    if ($pie=~/\[[0-9]+,\] .+ .+$/){
				($exp1, $exp2)=$pie=~/\[[0-9]+,\] (.+) (.+)$/;
				if ($exp1 > 5){
				    $hightot++;
				}
				if ($exp2 > 5){
				    $hightot++;
				}
				$exptot+=2;
			    }
			}
			print "HIGH: $hightot EXP: $exptot PIE: $pie2\n";
			$expercent=$hightot/$exptot if ($exptot);
			#can't use chisq because it's wrong
			#look at the correlation
			$halfp1=$totalnolib+1;
			$twice=$totalnolib*2;
			$R->send(qq`a<-x[1:${totalnolib}]`);
			$R->send(qq`b<-x[${halfp1}:${twice}]`);
			$R->send(qq`j<-cor(a,b)`);
			$R->send(q`print(j)`);
			$ret4 = $R->read ;
			($correlation)=$ret4=~/^\[[0-9].*\] (.+)$/;
			#what do you want to do
			if ($expercent<0.8){
			    #if the expected values are too low
			    #then the chisq will be incorrect, simulate pvalue with monte carlo simulation
                            $R->send(qq`alleles<-matrix(c($string),nr=2)`);
                            $R->send(q`x<-t(alleles)`);
                            #first try fishers test                                                                                                                                          
                            $R->send(qq`h<-chisq.test(x,simulate.p.value = TRUE, B = 10000)`);
                            $R->send(q`print(h$p.value)`);
                            $ret5 = $R->read ;
			    
			    if ($ret5=~/\[[0-9]/){
				($spvalue) = $ret5=~/\[[0-9].*\] (.+)$/;
			    }
			    if ($spvalue>0.005){
				$change++;
				$pvalue="Sim: $spvalue Chi: $cpvalue Man: $manpvalue Cor: $correlation Exp: $expercent";
			    }
			} elsif ($cpvalue){
			    #just go with the calculated pvalue
			    $change++ if ($cpvalue>0.005);
			    $pvalue="Chi: $cpvalue Man: $manpvalue Cor: $correlation Exp: $expercent" if ($cpvalue>0.005);
			} elsif ($manpvalue){
			    #go with the manual pvalue
			    $change++ if ($manpvalue>0.005);
                            $pvalue="Chi: $cpvalue Man: $manpvalue Cor: $correlation Exp: $expercent" if ($manpvalue>0.005);
			} elsif ($correlation){
			    #something weird is happening go with correlation
			    if ($correlation>0.5){
				$change++;
				$pvalue="Only Cor: $correlation";
			    }
			} else {
			    print "Missing all values: $oid $id\n";
			}
		    }
		}
		if ($change){
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
		    print "Pvalue: $pvalue\n";
		}
	    }
	}
    }
    print "$oid: Done testing as parent\n";
}

$R->stopR() ; 
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
