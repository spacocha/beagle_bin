#! /usr/bin/perl -w

die "Use this program to make random erros in sequence data
This will use the geometric distribution
error_prob- this is the probability used to determine whether a sequence will have an error (0.85 seems ok)
seq_prob- This is the probability used to determine where the error is from the 3' end (0.5 is ok)
For prob use 0.9 for mostly 0's and 0.5 will give about half 0's
Usage: fasta seqs total_no error_prob seq_prob > redirect" unless (@ARGV);
($tab, $readprob, $seqprob) = (@ARGV);
chomp ($tab);
chomp ($readprob);
chomp($seqprob);

open (IN, "<$tab" ) or die "Can't open $tab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $seqcount, $sequence) = split ("\t", $line);
    $counthash{$name}=$seqcount;
    $seqhash{$name}=$sequence;
} 
close (IN);

foreach $name (
