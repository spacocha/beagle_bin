#! /usr/bin/perl -w
#
#

	die "Use this program to run chisq on samples
file.dat made by UC2bar_count.pl and has all OTUs in cols and libs in rows
Usage: file.dat > Redirect\n" unless (@ARGV);
	($file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file2);
$first=1;
open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, @seqs)=split ("\t", $line);
		if ($first){
		    $first=();
		    (@OTUs)=@seqs;
		} else {
		    $i = @seqs;
		    $j = 0;
		    until ($j >=$i){
			#record the counts of each FreClu cluster in each library in a hash
			$hash{$OTUs[$j]}{$name}=$seqs[$j];
			$j++;
		    }
		}
       	}
close (IN);

foreach $OTU1 (sort keys %hash){
    #get the sum of all bars for OTU1
    $OTU1sum=0;
    foreach $bar (sort keys %{$hash{$OTU1}}){
	$OTU1sum+=$hash{$OTU1}{$bar};
    }
    #test against all other OTUs in the dataset
    foreach $OTU2 (sort keys %hash){
	#don't duplicate tests
	next if ($OTU1 eq $OTU2);
	next if ($done{$OTU1}{$OTU2});
	$done{$OTU1}{$OTU2}++;
	$done{$OTU2}{$OTU1}++;
	#get the sum of all the bars for OTU2
	$OTU2sum=0;
	foreach $bar (sort keys %{$hash{$OTU2}}){
	    $OTU2sum+=$hash{$OTU2}{$bar};
	}
	$OTUsum=$OTU1sum+$OTU2sum;
	#get the sum of each library
	%barhash=();
	$bartotal = 0;
	foreach $bar (sort keys %{$hash{$OTU1}}){
	    $barhash{$bar}=$hash{$OTU1}{$bar}+$hash{$OTU2}{$bar};
	    $bartotal+=$hash{$OTU1}{$bar};
            $bartotal+=$hash{$OTU2}{$bar};
	}
	#OTU total should equal bar total or there's a problem
	die "OTU $OTUsum Bar $bartotal\n" unless ($bartotal==$OTUsum);
	#what is the expected count for each entry
	$chisq = 0;
	foreach $bar (sort keys %{$hash{$OTU1}}){
	    $OTU1frac=$OTU1sum/$OTUsum;
	    $OTU2frac=$OTU2sum/$OTUsum;
	    $barfrac = $barhash{$bar}/$bartotal;
	    $expected1=$OTUsum*$OTU1frac*$barfrac;
            $expected2=$OTUsum*$OTU2frac*$barfrac;
	    if ($expected1){
		$value1 = (($hash{$OTU1}{$bar} - $expected1)**2)/$expected1;
		$chisq+=$value1;
	    } elsif ($hash{$OTU1}{$bar}) {
		die "There's a problem because I have an observed but no expected\n";
	    }
            if ($expected2){
                $value2 = (($hash{$OTU2}{$bar} - $expected2)**2)/$expected2;
		$chisq+=$value2;
            } elsif ($hash{$OTU2}{$bar}) {
                die "There's a problem because I have an observed but no expected\n";
	    }
#           die "$bar $OTU1 $OTU2
#Observed OTU1 $hash{$OTU1}{$bar}
#Expected: $OTUsum $OTU1frac $barfrac $expected1
#Observed OTU2 $hash{$OTU2}{$bar}
#Expected: $OTUsum $OTU2frac $barfrac $expected2
#$value1
#$value2
#$chisq\n";  
	}
#	print "\t$OTU1\t$OTU2\n";
#	foreach $bar (sort keys %{$hash{$OTU1}}){
#	    print "$bar\t$hash{$OTU1}{$bar}\t$hash{$OTU2}{$bar}\n";
#	}
#	print "Chi sq $chisq\n";
#	die;
	$newchisq=$chisq;
	print "$OTU1\t$OTU2\t$newchisq\n";
	$chisq=0;
    }
}

