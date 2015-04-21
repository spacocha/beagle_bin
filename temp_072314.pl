#! /usr/bin/perl -w

die "Usage: mat> redirect\n" unless (@ARGV);
($mat) = (@ARGV);
chomp ($mat);

$first=1;
open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($mock, @pieces)=split ("\t", $line);
    if ($first){
	print "$mock";
	foreach $piece (@pieces){
            print "\t$piece";
	    @headers=@pieces;
	}
	print "\n";
	$first=();
    } else {
	$i=0;
	$j=@pieces;
	until ($i >=$j){
	    $hash{$headers[$i]}+=$pieces[$i];
	    $i++;
	}
    }	
}

close (IN);

foreach $head (sort keys %hash){
    print "$head\t$hash{$head}\n";
}
