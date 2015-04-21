#! /usr/bin/perl -w

die "Usage: error_file tab namecol fasta .mat_file output >Redirect pvalues\n" unless (@ARGV);
($error, $tab, $namecol, $fasta, $matfile, $output) = (@ARGV);
chomp ($tab);
chomp ($namecol);
$namecolm1=$namecol-1;
chomp ($error);
chomp ($fasta);
chomp ($matfile);
chomp ($output);
makepvaluehash();
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
	    $i++;
	}
    }
	  
}
close (IN);

open (IN, "<$error" ) or die "Can't open $error\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line=~/^Change/);
    next unless ($line);
    ($child, $parent) =$line=~/^Change (ID[0-9]{7}P) \=\> (ID[0-9]{7}P)\t/;
    die "MISSING: $line\n" unless ($child && $parent);

    #some might be duplicated
    next if ($done{$child}{$parent});
    die "There's a problem with this pair $child $parent\n" if ($done{$parent}{$child});
    $done{$child}{$parent}++;
    
    #check to see if these two are differentially distributed across libraries
    $OTU1=$child;
    $OTU2=$parent;
    $fishpvalue=();
    #try fishers exact test first
    if (-e "/home/spacocha/fisher.output"){
	system ("rm /home/spacocha/fisher.output");
    }
    open (FISH, ">/home/spacocha/file.dat") or die "Can't open file.dat\n";
    print FISH "$OTU1\t$OTU2\n";
    foreach $bar (keys %{$mathash{$OTU1}}){
	print FISH "$mathash{$OTU1}{$bar}\t$mathash{$OTU2}{$bar}\n" if ($mathash{$OTU1}{$bar} || $mathash{$OTU2}{$bar});
    }
    close (FISH);
    system ("/home/spacocha/bin/R-2.12.1/bin/R --slave --vanilla < /home/spacocha/bin/fisher >> /home/spacocha/fisher.err");
    $pvalue=();
    if (-e "/home/spacocha/fisher.output"){
	open (FISHIN, "</home/spacocha/fisher.output") or die "Can't open /home/spacocha/fisher.output\n";
	while ($fishline=<FISHIN>){
	    chomp ($fishline);
	    ($fishpvalue)=split ("\t", $fishline);
	}
	close (FISHIN);
	
    }
    if ($fishpvalue){
	#the fishers exact test worked- use that
	$pvalue=$fishpvalue;
	$test="fisher";
    } else {
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
		$pvalue=0.004;
	    } else {
		$pvalue=0.006;
	    }
	} else {
	    $pvalue=1;
	}

       	$test="chisq_man";
    }
    if ($pvalue>=0.005){
	$hash{$child}=$parent;
	print "$child $parent $test $pvalue\n";
    }
    $test=();
    $pvalue=();
    $critvalue=();
}
close (IN);

open (IN, "<$tab" ) or die "Can't open $tab\n";
open (OUT, ">${output}.tab") or die "Can't open ${output}.tab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    $first=1;
    foreach $piece (@pieces){
	if ($first){
	    print OUT "$piece";
	    $first=();
	} else {
	    print OUT "\t$piece";
	}
    }
    if ($hash{$pieces[$namecolm1]}){
	print OUT "\t$hash{$pieces[$namecolm1]}\n";
    } else {
	print OUT "\t$pieces[$namecolm1]\n";
    }
} 
close (IN);
close (OUT);

$/=">";
open (IN, "<$fasta" ) or die "Can't open $fasta\n";
open (OUT, ">${output}.fa") or die "Can't open ${output}.fa\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @seqs) =split ("\n", $line);
    ($sequence)=join ("", @seqs);
    unless ($hash{$name}){
	print OUT ">$name\n$sequence\n";
    }

}
close (IN);
close (OUT);
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
	    die "There's a problem because I have an observed but no expected\n";
	}
	if ($expected2){
	    $value2 = (($mathash{$OTU2}{$bar} - $expected2)**2)/$expected2;
	    $chisq+=$value2;
	} elsif ($mathash{$OTU2}{$bar}) {
	    die "There's a problem because I have an observed but no expected\n";
	}
    }
    $newchisq=$chisq;
    return ($newchisq);
    $chisq=0;
    
}

sub makepvaluehash {
    #pvalues from pg 655 of Applied Statistics and Probability for Engineers Mongomery and Runger
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
