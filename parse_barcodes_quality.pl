#! /usr/bin/perl
#
#

use lib "/home/spacocha/bin";
die "Usage: <fastq> redirect\n" unless (@ARGV);
($file1) = (@ARGV);

require "/home/spacocha/bin/subroutines.pm";
die "Please follow command line args\n" unless ($file1);
chomp ($file1);

fastq_mat();

open (IN1, "<$file1") or die "Can't open $file1\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    (@stuff)=split("\t", $line1);
    $seq=$stuff[8];
    $qual=$stuff[9];
    if ($seq=~/[A-z]{7}/){
	(@pieces)=split ("", $qual);
	$i=0;
	$j=@pieces;
	until ($i>=$j){
	    if ($qualhash{$pieces[$i]}){
		#record how many times each quality value was seen with each barcode seq
		$recordhash{$seq}{$qualhash{$pieces[$i]}}++;
	    } else {
		die "Missing a quality score $pieces[$i]\n";
	    }
	    $i++;
	}
    }
}

foreach $seq (sort keys %recordhash){
    $total=();
    $running=();
    foreach $qual (sort keys %{$recordhash{$seq}}){
	#running is the quality score (40, 39, 25 etc) times the number of times it was seen
	$running+=$qual*$recordhash{$seq}{$qual};
	#total is the total number of quality scores counted
	$total+=$recordhash{$seq}{$qual};
    }
    $average=${running}/${total};
    print "$seq\t$running\t$total\t$average\n";
}
