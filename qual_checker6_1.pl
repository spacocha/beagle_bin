#! /usr/bin/perl -w
#
#

	die "Usage: tab namecol full_seqcol correspding_qualcol aligncol outputname\n" unless (@ARGV);
	($file1, $namecol, $seqcol, $qualcol, $aligncol, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
chomp ($namecol);
chomp ($seqcol);
chomp ($qualcol);
chomp ($aligncol);
chomp ($output);
($seqcolm1)=$seqcol-1;
($aligncolm1)=$aligncol-1;
($qualcolm1)=$qualcol-1;
($namecolm1)=$namecol-1;
fastq_mat();
#first get the total counts for each aligned sequence
print "Opeing $file1\n";
open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/fffHWI-EAS413_0041:1:/);
    (@pieces)=split ("\t", $line);
    ($align1)=$pieces[$aligncolm1];
    next if ($align1=~/remove/);
    $countaseq{$align1}++;
    #assign a count number to each name
    $namecounthash{$align1}{$pieces[$namecolm1]}=$countaseq{$align1};
    $countnamehash{$align1}{$countaseq{$align1}}=$pieces[$namecolm1];
    #print "$align1\n";
}
close (IN);
#now pick 1,000 names (by their numbers) at most for each value

$totalpro=1;
$totalfile=1;
print "Picking 1,000 names\n";
$count=1000;
open (OUT, ">${output}.${totalfile}.txt") or die "Can't open ${output}.${totalfile}.txt\n";
foreach $align1 (sort keys %countaseq){
    print "Working on: $align1\n";
    if ($totalpro>1000){
	close (OUT);
	$totalfile++;
	open (OUT, ">${output}.${totalfile}.txt") or die "Can't open ${output}.${totalfile}.txt\n";
	$totalpro=1;
    }
    $totalpro++;
    $size=$countaseq{$align1};
    if ($size>1000){
	$i = 1;
	until ($i > $count){
	    $got = ();
	    until ($got){
		($random) = int(rand($size));
		if ($randseqhash{$align1}{$random}){
		    #already recorded this number
		    $got=();
		} else {
		    #this sequence will be used
		    $randseqhash{$align1}{$random}++;
		    $got++;
		    print OUT "$align1\t$countnamehash{$align1}{$random}\n";
		}
	    }
	    $i++;
	}
    } else {
	#there are fewer than 1,000 counts so use all of the names in the set
	foreach $name (keys %{$namecounthash{$align1}}){
	    $randseqhash{$align1}{$namecounthash{$align1}{$name}}++;
	    print OUT "$align1\t$name\n";
	}
    }
}

sub fastq_mat{

    %qualhash=("B", "0", "C", "3", "D", "4", "E", "5", "F", "6", "G", "7", "H", "8", "I", "9", "J", "10", "K", "11", "L", "12", "M", "13", "N", "14", "O", "15", "P", "16", "Q", "17", "R", "18", "S", "19", "T", "20", "U", "21", "V", "22", "W", "23", "X", "24", "Y", "25", "Z", "26", "[", "27", "\\", "28", "]", "29", "^", "30", "_", "31", "`", "32", "a", "33", "b", "34", "c", "35", "d", "36", "e", "37", "f", "38", "g", "39", "h", "40", "i", "41");

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

    $total = (keys %hash);
    return $std = 0 if ($total <= 1);               #can not find stdev if there are no values
    $sum =0;                                        #blank this value

    foreach $value (keys %hash){                    #find the sum of all values
	$sum+=$hash{$value};
    }

    $average = $sum/$total;                         #calculate the mean or average
        
    $ysq = 0;                                       #clear values
    $ysum = 0;

    foreach $value (keys %hash){                    #for each find the square of the difference from the mean
	$y = $hash{$value} - $average;
	$ysq = $y*$y;
	$ysum+=$ysq;                            #sum all squared values
    }
        
    $std = sqrt($ysum/($total - 1));                #find the square root of the squared sum divided by total -1
    return $std;
}
