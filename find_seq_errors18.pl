 #! /usr/bin/perl -w
#
#

	die "Use this program to fix errors in sequencing data
Usage: dist mat_file fafile R_file output\n" unless (@ARGV);
	($distfile, $matfile, $fafile, $Rfile, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($matfile);
chomp ($distfile);
chomp ($matfile);
chomp ($fafile);
chomp ($Rfile);
chomp ($output);
$printscreen=0;
$pvaluecutoff=0.0005;
print "OLDSTATS:$oldstats\n" if ($printscreen);
#record library distribution data
$first=1;
print "Reading: mat file\n" if ($printscreen);
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
    $disthash{$OTU1}{$OTU2}=$dist;
    $disthash{$OTU2}{$OTU1}=$dist;
    $gotdist{$OTU1}{$OTU2}++;
    $gotdist{$OTU2}{$OTU1}++;
}
close (IN);
print "Reading in fa file: $fafile\n" if ($printscreen);
$/=">";
open (IN, "<${fafile}") or die "Can't open BP ${fafile}\n";
while ($line = <IN>){
    chomp ($line);
    next unless ($line);
    ($OTU1, @pieces) = split ("\n", $line);
    if ($OTU1=~/^.+\_[0-9]+$/){
	($shrtOTU)=$OTU1=~/^(.+)\_[0-9]+$/;
    } else {
	$shrtOTU=$OTU1;
    }
    ($sequence)=join ("", @pieces);
    $seqhash{$shrtOTU}=$sequence;
}
close (IN);

open (OUT, ">${output}") or die "Can't open $output\n";
$distcutoff=0.1;

#Do alignment mistakes first
if ($skipalignment){
    print "Skipping alignment\n" if ($printscreen);
} else {
    print "Alignment mistakes\n" if ($printscreen);
    print OUT "Alignment mistakes\n";
    foreach $id (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
	#don't evaluate as a parent if it's already a child
	die "No seqeunce $id $seqhash{$id}\n" unless ($seqhash{$id});
	$gapless2=$seqhash{$id};
	$gapless2=~s/-//g;
	#check if it's already done
	if ($alignmenthash{$gapless2}){
	        #this sequence is the same as a more abundant (or already done) sequence
	        #check if the alignment is the only difference
	    $oid=$alignmenthash{$gapless2};
	    print OUT "Changefrom,${id},${oid},Changeto,$id,$oid,Alignment mistake,Done\n";
	    $parenthash{$oid}++;
	    $childhash{$id}++;
	} else {
	    $got3=();
	    foreach $gapless3 (sort keys %alignmenthash){
		$oid=$alignmenthash{$gapless3};
		next unless ($disthash{$oid}{$id} <= $distcutoff || $abundhash{$oid} > $abundhash{$id});
		if ($gapless3=~/$gapless2/ || $gapless2=~/$gapless3/){
		    print OUT "Changefrom,${id},${oid},Changeto,$id,$oid,Alignment mistake:contained,Done\n";
		    $got3++;
		    last;
		}
	    }
	    unless ($got3){
		$alignmenthash{$gapless2}=$id;
	    }
	}
	print OUT "$id: Done testing alignment\n";
	print "$id: Done testing alignment\n" if ($printscreen);
    }
    print OUT "Finished Alignment\n";
}


#print "Finding non-alignment mistakes\n" if ($printscreen);
foreach $oid (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
    %resabundhash=();
    #in this step we want to find things that are less abundant and look at all of the things that are closely related
    #Take the distribution of chisq values and find the best one
    #next unless ($examplehash{$oid});
    next if ($parenthash{$oid});
    #print OUT "OID: $oid $abundhash{$oid}\n";
    foreach $id (sort {$disthash{$oid}{$a} <=> $disthash{$oid}{$b}} keys %{$disthash{$oid}}){
	next if ($id eq "outgroup");
	#only evaluate things that have a distance in the file (some files are too long to keep all pairs)
	next unless ($gotdist{$oid}{$id});
	#only evaluate things that are at higher abundance, not already changed and not to distant
	next if ($id eq $oid || 10*$abundhash{$oid} > $abundhash{$id} || $disthash{$oid}{$id} > $distcutoff || $childhash{$id});
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
	    print "first try fishers test\n" if ($printscreen);
	    system ("R --slave --vanilla --silent < ${Rfile}.fis >> ${Rfile}.err");		    
	    if (-e "${Rfile}.fisp"){
		print "Fish worked\n" if ($printscreen);
		$fpvalue=();
		open (RES, "<${Rfile}.fisp") or die "Can't open ${Rfile}.fisp\n";
		while ($Rline=<RES>){
		    chomp ($Rline);
		    next unless ($Rline);
		    print "fisp Rline: $Rline\n" if ($printscreen);
		    ($fpvalue)=$Rline=~/^(.+)/;
		    print "fpvalue $fpvalue\n" if ($printscreen);
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
		    print "Got chip\n" if ($printscreen);
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
	$respvalhash{$oid}{$id}=$pvalue;
	$resabundhash{$id}=$abundhash{$id};
    }
    foreach $id (sort {$resabundhash{$b} <=> $resabundhash{$a}} keys %resabundhash){
	#print OUT "Evaluating $id\n";
	if ($respvalhash{$oid}{$id} > $pvaluecutoff){
	    print OUT "Changefrom,$oid,$id,Changeto,DIST,$disthash{$oid}{$id},PVAL,$respvalhash{$oid}{$id}";
	    #when it's assigned as a parent, don't evalualte as a child                                                                                                                              
	    $parenthash{$id}++;
	    #when it's assigned as a child, don't evaluate as a parent                                                                                                                               
	    $childhash{$oid}++;
	    print OUT ",Done\n";
	    last;
	}
    }
    print OUT "$oid: Done testing as child\n";
}

print OUT "Finished\n";
close (OUT);

