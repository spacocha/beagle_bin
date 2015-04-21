#! /usr/bin/perl -w

die "Usage: tab > redirect\n" unless (@ARGV);
($tab) = (@ARGV);
chomp ($tab);

open (IN, "<$tab" ) or die "Can't open $tab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, $lib, $forseq, $qual)=split ("\t", $line);
    ($rand, $checkseq)=$forseq=~/^(.{4})(.+)$/;
    print "$info\t$lib\t$forseq\t$qual\t$checkseq\n";
    
} 
close (IN);


