#! /usr/bin/perl -w

die "Usage: map_plus fastq\n" unless (@ARGV);
($map, $new) = (@ARGV);
chomp ($new);
chomp ($map);

open (IN, "<$map" ) or die "Can't open $map\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, $goodseq, @seqs) = split ("\t", $line);
    foreach $seq (@seqs){
	$hash{$seq}=$goodseq;
    }
}
close (IN);

$/="@";
open (IN, "<$new" ) or die "Can't open $new\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs) = split ("\n", $line);
    ($first, $bar)=$info=~/^(.+)\#.*(.{7})\/[0-9]$/;
    ($lcbar)=lc($bar);
    if ($hash{$bar}){
	print "\@${info}\n$hash{$bar}\n+\n$lcbar\n";
    } else {
	print "\@${info}\n$bar\n+\n$lcbar\n";
    }
} 
close (IN);

