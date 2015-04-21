 #! /usr/bin/perl -w
#
#

	die "Use this program to fix errors in sequencing data
Usage: bp_freq_file align_fa dist mat_file R_file output\n" unless (@ARGV);
	($bpfreq, $align, $distfile, $matfile, $Rfile, $output, $oldstats) = (@ARGV);

	die "Please follow command line args\n" unless ($matfile);
chomp ($bpfreq);
chomp ($align);
chomp ($distfile);
chomp ($matfile);
chomp ($Rfile);
chomp ($oldstats);
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
	until ($i>$j){
	    $mathash{$OTU}{$headers[$i]}=$libs[$i] if ($headers[$i]);
	    $matbarhash{$headers[$i]}++ if ($headers[$i]);
	    $total+=$libs[$i];
	    $i++;
	}
	$abundhash{$OTU}=$total;
    }
      
}
close (IN);
print "BP file\n" if ($printscreen);
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
print "Reading in dist file: $distfile\n" if ($printscreen);
open (IN, "<${distfile}") or die "Can't open BP ${distfile}\n";
while ($line = <IN>){
    chomp ($line);
    next unless ($line);
    ($OTU1, $OTU2, $dist) = split ("\t", $line);
    $disthash{$OTU1}{$OTU2}=$dist;
    $disthash{$OTU2}{$OTU1}=$dist;
}
close (IN);


$/=">";
open (INFA, "<${align}") or die "Can't open ALIGN ${align}\n";
print "Reading align\n" if ($printscreen);
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

#Do alignment mistakes first
open (OUT, ">${output}") or die "Can't open $output\n";
if ($skipalignment){
    print "Skipping alignment\n" if ($printscreen);
} else {
    print "Alignment mistakes\n" if ($printscreen);
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
	print "$nid: Done testing alignment\n" if ($printscreen);
    }
    print OUT "Finished Alignment\n";
}
$distcutoff=0.05;
print "Finding non-alignment mistakes\n" if ($printscreen);
foreach $oid (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
    #in this step we want to find things that are less abundant and look at all of the things that are closely related
    #Take the distribution of chisq values and find the best one
    print "OID: $oid $abundhash{$oid}\n" if ($printscreen);
    foreach $id (sort {$disthash{$oid}{$a} <=> $disthash{$oid}{$b}} keys %{$disthash{$oid}}){
	next if ($id eq "outgroup");
	#only evaluate things that are at higher abundance, not already changed and not to distant
	next if ($id eq $oid || $abundhash{$oid} > $abundhash{$id} || $disthash{$oid}{$id} > $distcutoff || $childhash{$id});
	#check to see if the alignment is the only thing that is different between these sequences
	#make a gapless sequence
	print "ID: $id $disthash{$oid}{$id}\n" if ($printscreen);
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
	#what is the frequency of mismatch bases
	foreach $i (@mismatch){
	    $base=$bases[$i];
	    $obase = $obases[$i];
	    $freq=$bpfreqhash{$i}{$base};
	    $ofreq=$bpfreqhash{$i}{$obase};
	    if ($freq*2 >=$ofreq){
		#this means it's a bad call, consider changing
		$warning{$i}{"freq"}="FCHANGE: ID base $i $base is more frequent ($freq) than ODI ($ofreq)";
		$keepfreq{$i}++;
	    } else {
		#this means there is not frequency related reason to change
		$warning{$i}{"freq"}="FNOTCHANGE: ID base $i $base is less frequent ($freq) than OID ($ofreq)";
	    }
	}
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

	    system ("R --slave --vanilla --silent < ${Rfile}.fis >> ${Rfile}.err");		    
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
		$pvalue=$fpvalue;
	    } else {
		#now try chisq
		$cpvalue=();
		system ("R --slave --vanilla --silent < ${Rfile}.chi >> ${Rfile}.err");
		
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
		    system ("R --slave --vanilla --silent < ${Rfile}.chisim >> ${Rfile}.err");
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
		    $pvalue=$spvalue;
		} elsif ($cpvalue){
		    #just go with the calculated pvalue
		    $pvalue=$cpvalue;
		} else {
		    print OUT "Missing all values: $oid $id\n";
		}
	    }
	}
	$respvalhash{$oid}{$id}=$pvalue;
    }
    foreach $id (sort keys %{$respvalhash{$oid}}){
	if ($respvalhash{$oid}{$id} > $pvaluecutoff){
	    print OUT "Changefrom,$id,$oid,Changeto,DIST,$disthash{$oid}{$id},PVAL,$respvalhash{$oid}{$id}";
	    #when it's assigned as a parent, don't evalualte as a child                                                                                                                              
	    $parenthash{$oid}++;
	    #when it's assigned as a child, don't evaluate as a parent                                                                                                                               
	    $childhash{$id}++;
	    foreach $i (sort {$a <=> $b} keys %warning){
		foreach $val (sort keys %{$warning{$i}}){
		    print OUT ",$id,$oid,$warning{$i}{$val}";
		    
		}
	    }
	    print OUT ",Done\n";
	    last;
	}
    }
    print OUT "$oid: Done testing as parent\n";
}

print OUT "Finished\n";
close (OUT);

