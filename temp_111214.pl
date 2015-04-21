#! /usr/bin/perl -w
#
#

	die "Remove duplicates
Usage: original > redirect\n" unless (@ARGV);
	($file1) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);

open (IN, "<$file1") or die "Can't open $file1\n";
while ($head=<IN>){
    chomp ($head);
    next unless ($head);
    ($seq=<IN>);
    ($head2=<IN>);
    ($qual=<IN>);
    print "MISSING SEQUENCE: $head $seq\n"  unless ($seq);
    if ($hashseq{$head}){
	die "$head\n$hashseq{$head}\n$seq\n$hashqual{$head}\n$qual\n";
	#print "$head\t$seq\n$head2\n$qual\n";
	#$hash{$head}++;
    } else{
	$hashseq{$head}=$seq;
	$hashqual{$head}=$qual;
    }
}
close (IN);

