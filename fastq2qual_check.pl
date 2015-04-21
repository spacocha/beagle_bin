#! /usr/bin/perl -w

die "Use this program to check the quality of your run
It will output the average quality of each base
Usage: fastq > redirect\n" unless (@ARGV);

($fastq)=(@ARGV);
chomp ($fastq);

$/="@";
fastq_mat();
open (IN, "<$fastq" ) or die "Can't open $fastq\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, $seq, $info2, $qual)=split ("\n", $line);
    (@qualbases)=split ("", $qual);
    (@bases)=split ("", $seq);
    $i=0;
    $j=@bases;
    until ($i >= $j){
	if ($bases[$i] eq "N"){
	    $Nhash{$i}++;
	}
	if ($qualhash{$qualbases[$i]}){
	    $qualvalues{$i}{$qualhash{$qualbases[$i]}}++;
	} else {
	    die "Can't recognize the quality value $qualbases[$i]\n";
	}
	$totalbases{$i}++;
	$i++;
    }
	
}
close (IN);
print "position\tNfrac\n";
#print out an average and standard deviation for each base
foreach $pos (sort {$a <=> $b} keys %totalbases){
    if ($totalbases{$pos}){
	if ($Nhash{$pos}){
	    $Nfraction = ($Nhash{$pos})/($totalbases{$pos});
	    $qualfract = $qualvalues{$pos}/$totalbases{$pos};
	    print "$pos\t$Nfraction\n";
	} else {
	    print "$pos\t0\n";
	}
    } else {
	die "No base total data for position $pos\n";
    }
}

print "Position\taveragequal\tstdevqual\n";
stdev();

sub fastq_mat{

    %qualhash=("B", "2", "C", "3", "D", "4", "E", "5", "F", "6", "G", "7", "H", "8", "I", "9", "J", "10", "K", "11", "L", "12", "M", "13", "N", "14", "O", "15", "P", "16", "Q", "17", "R", "18", "S", "19", "T", "20", "U", "21", "V", "22", "W", "23", "X", "24", "Y", "25", "Z", "26", "[", "27", "\\", "28", "]", "29", "^", "30", "_", "31", "`", "32", "a", "33", "b", "34", "c", "35", "d", "36", "e", "37", "f", "38", "g", "39", "h", "40", "i", "41");

}

sub stdev {
        
        #input a hash with the values to be averaged and stdev'd
        #from Biometry Sokal et al (?)
    #pass %hash with number (1,2,3) as keys and values to be checked as values
    my $total;
    my $std;
    my $sum;
    my $value;
    my $average;
    my $ysq;
    my $ysum;
    my $y;

    $sum =0;                                        #blank this value

    foreach $position (sort {$a <=> $b} keys %qualvalues){                    #find the sum of all values
	$sum=0;
	foreach $number (keys %{$qualvalues{$position}}){
	    #each quality score is stored as the number of 10's (for example) at position 12
	    #so instead of summing up each, just multiply by the value and the number of time that value was seen
	    $add=$qualvalues{$position}{$number}*$number;
	    $sum+=$add;
	}

	$average = $sum/$totalbases{$position};                         #calculate the mean or average
        
	$ysq = 0;                                       #clear values
	$ysum = 0;
	
	foreach $value (keys %{$qualvalues{$position}}){                    #for each find the square of the difference from the mean
	    $y = $value - $average;
	    $ysq = $y*$y;
	    $mysq = $ysq*$qualvalues{$position}{$value};
	    $ysum+=$mysq;                            #sum all squared values
	}
        
	$std = sqrt($ysum/($totalbases{$position} - 1));                #find the square root of the squared sum divided by total -1
	print "$position\t$average\t$std\n";
    }

}
