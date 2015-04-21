#! /usr/bin/perl -w
#
#

	die "Use this program to calculate the standard deviation across the entire populatioin
count_table should be a matrix with FreClu cluster counts in each library
bar_col_1 and bar_col_2 are the column nos of the duliplated sample
Usage: count_table bar_col_1 bar_col_2 > Redirect\n" unless (@ARGV);
	($file2, $bar1, $bar2) = (@ARGV);

	die "Please follow command line args\n" unless ($bar2);
chomp ($file2);
chomp ($bar1);
chomp ($bar2);

$bar1ind= $bar1-1;
$bar2ind= $bar2-1;
$first=1;
open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($freclu, @counts)=split ("\t", $line);
		if ($first){
		    $first=();
		} else {
		    $total = 2;
		    %hash1 = ();
		    $hash1{$counts[$bar1ind]}++;
		    $hash1{$counts[$bar2ind]}++;
		    stdev ();
		    $mu = $average;
		    $sig = $std;
		    #this is the calculation according to Wikipedia, check this before publication
		    $runmutop = $runmutop + $total*$mu;
		    $runmubot = $runmubot+ $total;
		    $runsigtop = $runsigtop + $total*($sig**2 + $mu**2);
		    $runsigbot = $runsigbot +$total;
		}

       	}
close (IN);

$totalmu = $runmutop/$runmubot;
$totalsig = sqrt($runsigtop/$runsigbot -$totalmu**2);
print "Total mu: $totalmu Total sig: $totalsig\n";

sub stdev {
        
        #input a hash with the values to be averaged and stdev'd
        #from Biometry Sokal et al (?)

    return $std = 0 if ($total == 0);               #can not find stdev if there are no values
    $sum =0;                                        #blank this value
    $total2=0;
    foreach $value (keys %hash1){                    #find the sum of all values
	$i=0;
	until ($i>=$hash1{$value}){
	    $sum+=$value;
	    $i++;
	    $total2++;
	}
    }

    $average = $sum/$total2;                         #calculate the mean or average
        
    $ysq = 0;                                       #clear values
    $ysum = 0;

    foreach $value (keys %hash1){                    #for each find the square of the difference from the mean
	$i=0;
	until ($i>=$hash1{$value}){
	    $y = $value - $average;
	    $ysq = $y*$y;
	    $ysum+=$ysq;                            #sum all squared values
	    $i++;
	}
    }
        
    $std = sqrt($ysum/($total2 - 1));                #find the square root of the squared sum divided by total -1
    $var=$std**2;
}
