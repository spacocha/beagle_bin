#! /usr/bin/perl -w
#
#

	die "Usage: OTU_IDno all_tab seqcol qualcol OTUcol seqlen> redirect\n" unless (@ARGV);
	($keep, $tabfile,  $seqcol, $qualcol, $OTUcol, $seqlen) = (@ARGV);

	die "Please follow command line args\n" unless ($qualcol);
chomp ($keep);
chomp ($tabfile);
chomp ($seqcol);
chomp ($qualcol);
chomp ($OTUcol);
chomp ($seqlen);
$seqcolm1=$seqcol-1;
$qualcolm1=$qualcol-1;
$OTUcolm1=$OTUcol-1;
fastq_mat();
$qhashcount=0;
open (IN, "<${tabfile}") or die "Can't open ${tabfile}\n";
while ($line = <IN>){
    chomp ($line);
    next unless ($line);
    (@pieces) = split ("\t", $line);
    ($fullseq)=$pieces[$seqcolm1];
    ($qual)=$pieces[$qualcolm1];
    ($OTU)=$pieces[$OTUcolm1];
    if ($OTU eq $keep){
	print "Found OTU\n";
	($newqual)=$qual=~/^(.{$seqlen})/;
	(@qbases)=split ("", $newqual);
	$i=0;
	foreach $qbase (@qbases){
	    if ($qualhash{$qbase}){
		$qhashcount++;
		$positionhash{$i}{$qhashcount}=$qualhash{$qbase};
	    } else {
		die "Missing base value: $qbase\n";
	    }
	    $i++;
	}
    }
}
close (IN);
	
foreach $pos (sort {$a <=> $b} keys %positionhash){
    %hash=();
    foreach $val (keys %{$positionhash{$pos}}){
	$hash{$val}=$positionhash{$pos}{$val};
    }
    #get std
    stdev();
    print "$pos\t$average\t$std\n";
}


sub fastq_mat{

    %qualhash=("B", "0", "C", "3", "D", "4", "E", "5", "F", "6", "G", "7", "H", "8", "I", "9", "J", "10", "K", "11", "L", "12", "M", "13", "N", "14", "O", "15", "P", "16", "Q", "17", "R", "18", "S", "19", "T", "20", "U", "21", "V", "22", "W", "23", "X", "24", "Y", "25", "Z", "26", "[", "27", "\\", "28", "]", "29", "^", "30", "_", "31", "`", "32", "a", "33", "b", "34", "c", "35", "d", "36", "e", "37", "f", "38", "g", "39", "h", "40", "i", "41");

}

sub stdev {
        
        #input a hash with the values to be averaged and stdev'd
        #from Biometry Sokal et al (?)
    #pass %hash with number (1,2,3) as keys and values to be checked as values
    my $total;
    #my $std;
    my $sum;
    my $value;
    #my $average;
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
