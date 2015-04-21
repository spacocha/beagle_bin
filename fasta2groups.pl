#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "All non-mapping sequences will be under heading NA
Usage: fasta mapping\n" unless (@ARGV);
	
chomp (@ARGV);
($fasta, $mapping) = (@ARGV);

open (IN, "<$mapping") or die "Can't open $mapping\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/^\#/);
    ($name, $seq)=split ("\t", $line);
    $hash{$seq}=$name;
}
close (IN);

$/=">";
open (IN, "<${fasta}") or die "Can't open $fasta\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name)=$line=~/^(.+?)\n/;
    ($lib)=$name=~/\#([A-z]+)\/*[0-9]*$/;
    if ($hash{$lib}){
	print "$name\t${hash{$lib}}\n";
    } else {
	print "$name\tNA\n";
    }
}
close (IN);

