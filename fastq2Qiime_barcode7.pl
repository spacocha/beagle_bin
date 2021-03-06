#! /usr/bin/perl -w

die "Usage: fastq\n" unless (@ARGV);
($new) = (@ARGV);
chomp ($new);

$/="@";
open (IN, "<$new" ) or die "Can't open $new\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs) = split ("\n", $line);
    ($first, $bar)=$info=~/^(.+)\#.*(.{7})\/[0-9]$/;
    ($lcbar)=lc($bar);
    print "\@${info}\n$bar\n+\n$lcbar\n";
} 
close (IN);

