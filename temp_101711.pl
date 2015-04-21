 #! /usr/bin/perl -w
#
#

	die "Use this program to fix errors in sequencing data
It will map low abundance sequences to higher abundance sequences if the mismatching base is of lower frequency of in the ref and it is ecologically differentiated
Usage: bp_freq_file align_fa mat_file R_file output oldstats\n" unless (@ARGV);
	($bpfreq, $align, $matfile, $Rfile, $output, $oldstats) = (@ARGV);

	die "Please follow command line args\n" unless ($Rfile);
chomp ($bpfreq);
chomp ($align);
chomp ($matfile);
chomp ($Rfile);
chomp ($oldstats);
chomp ($output);

print "OLDSTATS:$oldstats\n" if ($oldstats);
#record library distribution data
$first=1;
print "Reading: mat file $matfile\n";
open (IN, "<$matfile" ) or die "Can't open $matfile\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @libs) =split ("\t", $line);
    $totalabund=0;
    if ($first){
	$first=();
	(@headers)=@libs;
    } else {
	$i=0;
	$j=@headers;
	until ($i>=$j){
	    $mathash{$OTU}{$headers[$i]}=$libs[$i] if ($headers[$i]);
	    $matbarhash{$headers[$i]}++ if ($headers[$i]);
	    $totalabund+=$libs[$i];
	    $i++;
	}
    }
#    print "$OTU\t$totalabund\n";
    $abundhash{$OTU}=$totalabund;
      
}
close (IN);
print "BP file $bpfreq\n";
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
print "Opening align $align\n";
open (INFA, "<${align}") or die "Can't open ALIGN ${align}\n";
#evaluate each sequence compared to the polyhashfreq
$first=1;
while ($faline=<INFA>){
    chomp ($faline);
    if ($first){
	$first=();
    } else {
	($id, $seq)=split ("\n", $faline);
	if ($id=~/^(.+)_[0-9]+$/){
	    ($newid, $abund)=$id=~/^(.+)_([0-9]+)$/;
	} else {
	    $newid=$id;
	}
	$seqhash{$newid}=$seq;

    }
}
close (INFA);

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
