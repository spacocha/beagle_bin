 #! /usr/bin/perl -w
#
#

	die "Use this program to fix errors in sequencing data
Usage: dist mat_file fafile R_file output oldstats\n" unless (@ARGV);
	($distfile, $matfile, $Rfile, $output, $oldstats) = (@ARGV);

	die "Please follow command line args\n" unless ($matfile);
chomp ($distfile);
chomp ($matfile);
chomp ($Rfile);
chomp ($oldstats);
chomp ($output);
$printscreen=1;
#define your cutoffs
$pvaluecutoff=0.0005;
$distcutoff=0.2;
$abundcutoff=10;
print "OLDSTATS:$oldstats\n" if ($printscreen);
#record library distribution data
$first=1;
if ($oldstats){
    $init=();
    print "Reading in oldstats file: $oldstats\n" if ($printscreen);
    open (IN, "<$oldstats" ) or die "Can't open $oldstats\n";
    while ($line =<IN>){
	chomp ($line);
	next unless ($line);
	if ($line=~/Changefrom,.+,.+,Changeto/){
	    ($id, $oid)=$line=~/Changefrom,(.+),(.+),Changeto/;
	    $parenthash{$oid}++;
	    $childhash{$id}++;
	} elsif ($line=~/Finished Alignment/){
	    $skipalignment++;
	} elsif ($line=~/Done testing as child/){
	    ($oid)=$line=~/^(.+): Done testing as child/;
	    $donehash{$oid}++;
	}
    }
    close (IN);
} else {
    $init=1;
}
print "Reading in mat file: $matfile\n" if ($printscreen);
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
	$total=0;
	until ($i>=$j){
	    $mathash{$OTU}{$headers[$i]}=$libs[$i] if ($headers[$i]);
	    $matbarhash{$headers[$i]}++ if ($headers[$i]);
	    $total+=$libs[$i];
	    $i++;
	}
	$abundhash{$OTU}=$total;
    }
      
}
close (IN);
print "Reading in dist file: $distfile\n" if ($printscreen);
open (IN, "<${distfile}") or die "Can't open BP ${distfile}\n";
while ($line = <IN>){
    chomp ($line);
    next unless ($line);
    ($OTU1, $OTU2, $dist) = split ("\t", $line);
    if ($disthash{$OTU1}{$OTU2} || $disthash{$OTU2}{$OTU1}){
	if ($dist < $disthash{$OTU1}{$OTU2} || $dist < $disthash{$OTU2}{$OTU1}){
	    $disthash{$OTU1}{$OTU2}=$dist;
	    $disthash{$OTU2}{$OTU1}=$dist;
	    $gotdist{$OTU1}{$OTU2}++;
	    $gotdist{$OTU2}{$OTU1}++;
	}
    } else {
	$disthash{$OTU1}{$OTU2}=$dist;
	$disthash{$OTU2}{$OTU1}=$dist;
	$gotdist{$OTU1}{$OTU2}++;
	$gotdist{$OTU2}{$OTU1}++;
    }
}
close (IN);

open (OUT, ">${output}") or die "Can't open $output\n";

#print "Finding non-alignment mistakes\n" if ($printscreen);
foreach $oid (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
    if ($init){
	#this is the most abundant one, see if it clears the threshold
	#otherwise, if you have singletons, they will all be seperate OTUs
	#because the most abundant one isn't even above the threshold
	if ($abundhash{$oid} < ${abundcutoff}){
	    $mergeall=1;
	    $allparent=$oid;
	} else {
	    $mergeall=();
	}
	$init=();
    }
    %resabundhash=();
    #in this step we want to find things that are less abundant and look at all of the things that are closely related
    #Take the distribution of chisq values and find the best one
    #next unless ($examplehash{$oid});
    next if ($parenthash{$oid} || $donehash{$oid});
    #print OUT "OID: $oid $abundhash{$oid}\n";
    foreach $id (sort {$disthash{$oid}{$a} <=> $disthash{$oid}{$b}} keys %{$disthash{$oid}}){
	#only evaluate things that have a distance in the file (some files are too long to keep all pairs)
	next unless ($gotdist{$oid}{$id});
	if ($mergeall){
	    unless ($oid eq $allparent){
		print OUT "Changefrom,${oid},${allparent},Changeto,DIST,MERGEALL,PVAL,MERGEALL,Done\n";
	    }
	} else {
	    #only evaluate things that are at higher abundance, not already changed and not to distant
	    next if ($id eq $oid || ${abundcutoff}*$abundhash{$oid} > $abundhash{$id} || $disthash{$oid}{$id} > $distcutoff || $childhash{$id});
	    #check to see if the alignment is the only thing that is different between these sequences
	    #make a gapless sequence
#	print OUT "ID: $id $disthash{$oid}{$id}\n";
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
		#print "they are in one library\n";
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
		system ("R --slave --vanilla --silent < ${Rfile}.fis >> ${Rfile}.err");		    
		if (-e "${Rfile}.fisp"){
		    $fpvalue=();
		    open (RES, "<${Rfile}.fisp") or die "Can't open ${Rfile}.fisp\n";
		    while ($Rline=<RES>){
			chomp ($Rline);
			next unless ($Rline);
			($fpvalue)=$Rline=~/^(.+)/;
		    }
		    close (RES);
		    $pvalue=$fpvalue;
		} else {
		    #now try chisq
		    #print "Fish didn't work, try chisq\n";
		    $cpvalue=();
		    system ("R --slave --vanilla --silent < ${Rfile}.chi >> ${Rfile}.err");
		    $gotchip=0;
		    if (-e "${Rfile}.chip"){
			$gotchip=1;
			open (RES, "<${Rfile}.chip") or die "Can't open ${Rfile}.chip\n";
			while ($Rline=<RES>){
			    chomp ($Rline);
			    #print "Rline chip $Rline\n";
			    ($cpvalue)=$Rline=~/^(.+)/;
			    #print "cpvalue $cpvalue\n";
			}
			close (RES);
		    } else {
			#print "Missing .chip\n";
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
			    #print "expected too low do simulation\n";
			    system ("R --slave --vanilla --silent < ${Rfile}.chisim >> ${Rfile}.err");
			    $spvalue=();
			    if (-e "${Rfile}.chisimp"){
				#print "got chipsimp\n";
				open (RES, "<${Rfile}.chisimp") or die "Can't open ${Rfile}.chisimp\n";
				while ($Rline=<RES>){
				    chomp ($Rline);
				    next unless ($Rline);
				    #print "Rline chisimp $Rline\n";
				    ($spvalue)=$Rline=~/^(.+)/;
				}
				close (RES);
			    }
			    $pvalue=$spvalue;
			} elsif ($gotchip){
			    #print "Expected ok going with cpvalue\n";
			    #just go with the calculated pvalue
			    $pvalue=$cpvalue;
			} else {
			    #print "Missing all values: $oid $id\n";
			}
		    } else {
			#print "Missing chisq too\n";
		    }
		}
	    }
	    #print "Recording Pvalue $oid $id Pvalue:${pvalue}\n";
	    #print OUT "Evaluating $id\n";
	    if ($pvalue > $pvaluecutoff){
		unless ($mergeall){
		    print OUT "Changefrom,$oid,$id,Changeto,DIST,$disthash{$oid}{$id},PVAL,$pvalue,Done\n";
		    #when it's assigned as a parent, don't evalualte as a child                                                                                                                              
		    $parenthash{$id}++;
		    #when it's assigned as a child, don't evaluate as a parent                                                                                                                               
		    $childhash{$oid}++;
		    last;
		}
	    }
	}
    }
    print OUT "$oid: Done testing as child\n";
}

print OUT "Finished\n";
close (OUT);

