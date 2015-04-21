#! /usr/bin/perl -w

die "Usage: list > redirect\n" unless (@ARGV);
($mat) = (@ARGV);
chomp ($mat);

open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    open (IN2, "<${line}") or die "Can't open ${line}\n";
    while ($line2=<IN2>){
	chomp ($line2);
	next unless ($line2=~/Position/);
	($orient, $pos, $number)=split ("\t", $line2);
	$hash{$orient}{$pos}+=$number;
    }
    close (IN2);
}
close (IN);

foreach $orient (sort keys %hash){
    foreach $pos (sort {$a <=> $b} keys %{$hash{$orient}}){
	print "$orient\t$pos\t$hash{$orient}{$pos}\n";
    }
}
