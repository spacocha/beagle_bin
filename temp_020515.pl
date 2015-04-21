#! /usr/bin/perl -w

die "Usage: summary_file> output\n" unless (@ARGV);
($file) = (@ARGV);
chomp ($file);

open (IN1, "<$file" ) or die "Can't open $file\n";

while ($line1 =<IN1>){
    chomp ($line1);
    next unless ($line1);
    if ($line1=~/^ .+: [0-9]+\.[0-9]+$/){
	($sample)=$line1=~/^ (.+): [0-9]+\.[0-9]+$/;
	print "$sample\n";
    }
}

close (IN1);
