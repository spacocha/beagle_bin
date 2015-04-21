#! /usr/bin/perl -w
#
#

	die "Check difference
Usage: Larger_file original\n" unless (@ARGV);
	($file1, $file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file1);
chomp ($file2);

open (IN, "<$file1") or die "Can't open $file1\n";
while ($head=<IN>){
    chomp ($head);
    next unless ($head);
    ($seq=<IN>);
    ($head2=<IN>);
    ($qual=<IN>);
    print "MISSING SEQUENCE: $head $seq\n"  unless ($seq);
    ($shorthead)=$head=~/^(.+)\/[1-3]$/;
    die "Missing shorthead $head $shorthead\n" unless ($shorthead);
    $hash{$shorthead}++;
}
close (IN);
print "Read in the data from $file1. Processing $file2\n";

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
    print "MISSING SEQUENCE: $head $seq\n"  unless ($seq);
    ($shorthead)=$head=~/^(.+)\/[1-3]$/;
    die "Missing shorthead $head $shorthead\n" unless ($shorthead);
    print "Missing $head\n" unless ($hash{$shorthead});
}
close (IN);




