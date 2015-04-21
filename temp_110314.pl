#! /usr/bin/perl -w
#
#

	die "Use this to split a fastq file for parallel processing
Usage: fastq_file barcode > output\n" unless (@ARGV);
	($file2, $barcode) = (@ARGV);

	die "Please follow command line args\n" unless ($barcode);
chomp ($file2);
chomp ($barcode);

open (IN, "<$file2") or die "Can't open $file2\n";
while ($head=<IN>){
    chomp ($head);
    next unless ($head);
    ($seq=<IN>);
    chomp ($seq);
    ($head2=<IN>);
    chomp ($head2);
    ($qual=<IN>);
    chomp ($qual);
    die "MISSING SEQUENCE: $head $seq\n"  unless ($seq);
    if ($head=~/${barcode}/){
	print  "$head\n$seq\n$head2\n$qual\n";
    }
}
close (IN);
close (OUT);

