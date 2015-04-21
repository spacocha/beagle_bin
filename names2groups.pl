#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: names_file\n" unless (@ARGV);
	
chomp (@ARGV);
($file) = (@ARGV);

open (IN, "<${file}") or die "Can't open $file\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, $nameline) = split ("\t", $line);
    (@names)=split (",", $nameline);
    foreach $name (@names){
	($lib)=$name=~/^(.+?)_[0-9]+$/;
	print "$name\t$lib\n";
    }
}
close (IN);

