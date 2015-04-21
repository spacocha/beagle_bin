#! /usr/bin/perl
#
#

	die "Usage: <fasta>  > redirect\n" unless (@ARGV);
	($file1) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);

$/=">";
open (IN1, "<$file1") or die "Can't open $file1\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($parent, @seqs)=split("\n", $line1);
    ($sequence)=join ("", @seqs);
    (@allbases)=split ("", $sequence);
    $j=@allbases;
    $sequence=~ s/-//g;
    $sequence =~ s/\.//g;    
    (@bases)=split ("", $sequence);
    $k=@bases;
    print "$parent $j $k $sequence\n" unless ($sequence=~/[ATGCN]/ || $j==5000 || $k <250 || $k > 350);
}
close (IN1);

