#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: fasta_file\n" unless (@ARGV);
	
chomp (@ARGV);
($file) = (@ARGV);

$/=">";
open (IN, "<${file}") or die "Can't open $file\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name)=$line=~/^(.+?)\n/;
    print "$name\t";
}
print "\n";
close (IN);

