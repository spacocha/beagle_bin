 #! /usr/bin/perl -w
#
#

	die "Use this program to fix errors in sequencing data
It will map low abundance sequences to higher abundance sequences with the following conditions:
Either lower frequency of the mismatched base or lower quality of the mismatched base
Up to three mismatches to a sequence at least 2 x more abundant than it
Usage: bp_freq_file align_fa qual_file stdv_file mat_file R_file output oldstats\n" unless (@ARGV);
	($bpfreq, $align, $qual, $stdev, $matfile, $Rfile, $output, $oldstats) = (@ARGV);

	die "Please follow command line args\n" unless ($matfile);
chomp ($bpfreq);
chomp ($align);
chomp ($qual);
chomp ($stdev);
chomp ($matfile);
chomp ($Rfile);
chomp ($oldstats);
chomp ($output);

print "OLDSTATS:$oldstats\n";
#record library distribution data
$first=1;
print "Reading: mat file\n";
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
print "BP file\n";
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
    print "Reading oldstats\n";
    while ($line = <IN>){
	chomp ($line);
	next unless ($line);
	if ($line=~/^(.+): Done testing as parent/){
	    ($childtest)=$line=~/^(.+): Done testing as parent/;
	    $skiphash{$childtest}++;
	    $parenthash{$childtest}++;
	} elsif ($line=~/^(.+): Done testing alignment/){
	    ($childtest)=$line=~/^(.+): Done testing alignment/;
            $skiphash3{$childtest}++;
	} elsif ($line=~/Finished Alignment/){
	    $skipalignment++;
	} elsif ($line=~/^Changefrom,(.+?),(ID[0-9]+P),Changeto,.+Done$/){
	    ($childtest, $parent)=$line=~/^Changefrom,(.+?),(ID[0-9]+P),Changeto,.+Done$/;
	    $skiphash2{$parent}{$childtest}++;
	    $childhash{$childtest}++;
	    $parenthash{$parent}++;
	} elsif ($line=~/Change.+Alignment mistake/){
	    ($childtest, $parent)=$line=~/^Change (.+?) => (ID[0-9]+P)/;
	    $skiphash2{$parent}{$childtest}++;
	    $childhash{$childtest}++;
	    $parenthash{$parent}++;
	}
    }
    close (IN);
}

$/=">";
open (INFA, "<${align}") or die "Can't open ALIGN ${align}\n";
print "Reading align\n";
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
print "Reading qual stdev\n";
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

makepvaluehash();
#Do alignment mistakes first
open (OUT, ">${output}") or die "Can't open $output\n";
if ($skipalignment){
    print "Skipping alignment\n";
} else {
    print "Alignment mistakes\n";
    print OUT "Alignment mistakes\n";
    foreach $nid (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
	#don't evaluate as a parent if it's already a child
	$gapless2=$seqhash{$nid};
	$gapless2=~s/-//g;
	#check if it's already done
	if ($alignmenthash{$gapless2}){
	    #this sequence is the same as a more abundant (or already done) sequence
	    #check if the alignment is the only difference
	    $oid=$alignmenthash{$gapless2};
	    $id=$nid;
	    print OUT "Changefrom,${id},${oid},Changeto,$id,$oid,Alignment mistake,Done\n";
	    $parenthash{$oid}++;
	    $childhash{$id}++;
	} else {
	    #mark as seen
	    $alignmenthash{$gapless2}=$nid;
	}
	print OUT "$nid: Done testing alignment\n";
	print "$nid: Done testing alignment\n";
    }
    print OUT "Finished Alignment\n";
}

print "Finding non-alignment mistakes\n";
foreach $oid (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
    #don't evaluate as a parent if it's already a child
    next if ($childhash{$oid});
    #don't evaluate things that were already checked in previous run
    next if ($skiphash{$oid});
    foreach $id (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
	#only evaluate things that are at lower abundances than oid and not already changed or evaluated
	next if ($id eq $oid || $abundhash{$id} >= $abundhash{$oid} || $childhash{$id} || $parenthash{$id} || $skiphash2{$oid}{$id} || $skiphash{$id});
	#check to see if the alignment is the only thing that is different between these sequences
	#make a gapless sequence
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
		    $warning{$i}{"qual"}="GOOD: This base is a gap $i";
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
			    $string="$string"."$mathash{$oid}{$bar}\t$mathash{$id}{$bar}\n";
			} else {
			    $string="$mathash{$oid}{$bar}\t$mathash{$id}{$bar}\n";
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
		    system ("rm ${Rfile}.fisp\n") if (-e "${Rfile}.fisp");
		    system ("rm ${Rfile}.chip\n") if (-e "${Rfile}.chip");
		    system ("rm ${Rfile}.chiexp\n") if (-e "${Rfile}.chiexp");
		    system ("rm ${Rfile}.chisimp\n") if (-e "${Rfile}.chisimp");
		    $fpvalue=();
		    $cpvalue=();
		    $spvalue=();
		    $manpvalue=();
		    open (INPUT, ">${Rfile}.in") or die "Can't open ${Rfile}.in\n";
		    print INPUT "$string\n";
		    close (INPUT);
		    open (FIS, ">${Rfile}.fis") or die "Can't open ${Rfile}.fis\n";
                    print FIS "x <- read.table(\"${Rfile}.in\", header = FALSE)
htest1<-fisher.test(x)
fisp <-htest1\$p.value
write.table(fisp,file=\"${Rfile}.fisp\",sep=\"\t\",row.names=FALSE,col.names=FALSE)\n";
		    close (FIS);
                    open (FIS, ">${Rfile}.chi") or die "Can't open ${Rfile}.chi\n";
                    print FIS "x <- read.table(\"${Rfile}.in\", header = FALSE)
htest2 <-chisq.test(x)
chip <-htest2\$p.value
chiexp <-htest2\$expected
print(htest2)
write.table(chip,file=\"${Rfile}.chip\",sep=\"\t\",row.names=FALSE,col.names=FALSE)
write.table(chiexp,file=\"${Rfile}.chiexp\",sep=\"\t\",row.names=FALSE,col.names=FALSE)\n";
                    close (FIS);
		    open (FIS, ">${Rfile}.chisim") or die "Can't open ${Rfile}.chisim\n";
		    print FIS "x <- read.table(\"${Rfile}.in\", header = FALSE)
htest3 <-chisq.test(x,simulate.p.value = TRUE, B = 10000)
chisimp <-htest3\$p.value
print(htest3)
write.table(chisimp,file=\"${Rfile}.chisimp\",sep=\"\t\",row.names=FALSE,col.names=FALSE)\n";

		    system ("/home/spacocha/bin/R-2.12.1/bin/R --slave --vanilla --silent < ${Rfile}.fis >> ${Rfile}.err");		    
		    #first try fishers test
		    if (-e "${Rfile}.fisp"){
			$fpvalue=();
			open (RES, "<${Rfile}.fisp") or die "Can't open ${Rfile}.fisp\n";
			while ($Rline=<RES>){
			    chomp ($Rline);
			    next unless ($Rline);
			    ($fpvalue)=$Rline=~/^(.+)\n/;
			}
			close (RES);
		  
			if ($fpvalue>0.005){
			    $change++;
			    $pvalue="Fish: $fpvalue";
			}
		    } else {
			#now get chisq
			$cpvalue=();
			system ("/home/spacocha/bin/R-2.12.1/bin/R --slave --vanilla --silent < ${Rfile}.chi >> ${Rfile}.err");
			
			if (-e "${Rfile}.chip"){
			    open (RES, "<${Rfile}.chip") or die "Can't open ${Rfile}.chip\n";
			    while ($Rline=<RES>){
				chomp ($Rline);
				next unless ($Rline);
				($cpvalue)=$Rline=~/^(.+)\n/;
			    }
			    close (RES);
			}
			#now get expected
			if (-e "${Rfile}.chiexp"){
			    open (RES, "<${Rfile}.chiexp") or die "Can't open ${Rfile}.chiexp\n";
			    while ($Rline=<RES>){
				chomp ($Rline);
				next unless ($Rline);
				(@retpie)=split ("\n", $Rline);
			    }
			    close (RES);
			}
			#now get chisim
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
			$exp1=();
			$exp2=();
			$hightot=();
			$exptot=();
			foreach $pie (@retpie){
			    if ($pie=~/^(.+)\t(.+)$/){
				($exp1, $exp2)=$pie=~/^(.+)\t(.+)$/;
				if ($exp1 > 5){
				    $hightot++;
				}
				if ($exp2 > 5){
				    $hightot++;
				}
				$exptot+=2;
			    }
			}
			$expercent=$hightot/$exptot if ($exptot);
			#can't use chisq because it's wrong
			#what do you want to do
			if ($expercent<0.8){
			    #if the expected values are too low
			    #then the chisq will be incorrect, simulate pvalue with monte carlo simulation
			    system ("/home/spacocha/bin/R-2.12.1/bin/R --slave --vanilla --silent < ${Rfile}.chisim >> ${Rfile}.err");
			    $spvalue=();
			    if (-e "${Rfile}.chisimp"){
				open (RES, "<${Rfile}.chisimp") or die "Can't open ${Rfile}.chisimp\n";
				while ($Rline=<RES>){
				    chomp ($Rline);
				    next unless ($Rline);
				    ($spvalue)=$Rline=~/^(.+)\n/;
				}
				close (RES);
			    }
			    
			    if ($spvalue>0.005){
				$change++;
				$pvalue="Sim: $spvalue Chi: $cpvalue Man: $manpvalue Exp: $expercent";
			    }
			} elsif ($cpvalue){
			    #just go with the calculated pvalue
			    if ($cpvalue>0.005){
				$change++;
				$pvalue="Chi: $cpvalue Man: $manpvalue Exp: $expercent";
			    }
			} elsif ($manpvalue){
			    #go with the manual pvalue
			    if ($manpvalue>0.005){
				$change++ if ($manpvalue>0.005);
				$pvalue="Chi: $cpvalue Man: $manpvalue Exp: $expercent" if ($manpvalue>0.005);
			    }
			} else {
			    print OUT "Missing all values: $oid $id\n";
			}
		    }
		}
		if ($change){
		    print OUT "Changefrom,$id,$oid,Changeto";
		    #when it's assigned as a parent, don't evalualte as a child
		    $parenthash{$oid}++;
		    #when it's assigned as a child, don't evaluate as a parent
		    $childhash{$id}++;
		    foreach $i (sort {$a <=> $b} keys %warning){
			foreach $val (sort keys %{$warning{$i}}){
			    print OUT ",$id,$oid,$warning{$i}{$val}";

			}
		    }
		    print OUT ",Pvalue,$pvalue,Done\n";
		}
	    }
	}
    }
    print OUT "$oid: Done testing as parent\n";
}

print OUT "Finished\n";
close (OUT);

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
