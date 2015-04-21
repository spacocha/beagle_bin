#! /usr/bin/perl -w

die "Usage: child_parent fasta > redirect\n" unless (@ARGV);
($tab, $fasta) = (@ARGV);
chomp ($tab);
chomp ($fasta);

open (IN, "<$tab" ) or die "Can't open $tab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/remove/);
    ($child, $childid, $parent, $parentid) = split ("\t", $line);
    $removeidhash{$childid}++;
} 
close (IN);

$/=">";
open (IN, "<$fasta" ) or die "Can't open $fasta\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/remove/);
    ($id, @seqs) = split ("\n", $line);
    next if ($removeidhash{$id});
    ($sequence)= join ("", @seqs);
    $sequence=~s/ //g;
    die "Weird\n" if ($checkseq{$sequence});
    print ">$id\n$sequence\n";
}

