#! /usr/bin/perl -w

die "Usage: mat > redirect\n" unless (@ARGV);
($mat) = (@ARGV);
chomp ($mat);

open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if (@headers){
	$i=0;
	$j=@pieces;
	until ($i >=$j){
	    $hash{$headers[$i]}+=$pieces[$i];
	    $i++;
	}
    } else {
	(@headers)=@pieces;
    }
}
close (IN);

foreach $head (sort keys %hash){
    print "$head\t$hash{$head}\n";
}
