#! /usr/bin/perl
#
#

	die "This program will take the names from the refined_fasta and keep the entries in the complete fasta that were in refined
The final file will look like complete, but with fewer entries, only those in both files
Usage: <refined_fasta> <complete_fasta> > redirect\n" unless (@ARGV);
	($file1, $file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file1);
chomp ($file2);

$/=">";
open (IN1, "<$file1") or die "Can't open $file1\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($parent, @seqs)=split("\n", $line1);
    ($seq)=join ("", @seqs);
    $hash{$parent}++;
}
close (IN1);

$first=1;
open (IN1, "<$file2") or die "Can't open $file2\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($parent, @seqs)=split("\n", $line1);
    if ($parent=~/^(.+_[0-9]+) /){
	($shrt)=$parent=~/^(.+_[0-9]+) /;
    } else {
	($shrt)=$parent;
    }
    if ($hash{$shrt}){
	($seq)=join ("", @seqs);
	print ">$shrt\n$seq\n";
    }
}
close (IN1);
