#! /usr/bin/perl -w

die "Usage: fasta1\n" unless (@ARGV);
($fasta1) = (@ARGV);
chomp ($fasta1);

$/=">";
open (IN, "<$fasta1" ) or die "Can't open $fasta1\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($newline, $seq)=split ("\n", $line);
    ($OTU, $abund)=$newline=~/^(.+)_([0-9]+)$/;
    print ">${OTU}/ab=${abund}\n$seq\n";
}
close (IN);

