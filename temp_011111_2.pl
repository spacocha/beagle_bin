#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: <bp_freq> <fasta> Redirect output\n" unless (@ARGV);
	
	chomp (@ARGV);
	($file1, $file2) = (@ARGV);
chomp ($file1);
chomp ($file2);

open (IN, "<$file1") or die "Can't open $file1\n";
while ($line1 = <IN>){
    chomp ($line1);
    next unless ($line1);
    next if ($line1=~/position/);
    ($position, $gap) = split ("\t", $line1);
    $removehash{$position}++ if ($gap == 100);
}
close (IN);

$/ = ">";
open (IN, "<$file2") or die "Can't open $file2\n";
while ($line1 = <IN>){	
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    print ">$info\n";
    ($sequence) = join ("", @pieces);
    $sequence =~tr/\n//d;
    (@bases) = split ("", $sequence);
    $i = 1;
    foreach $base (@bases){
	print "$base" unless ($removehash{$i});
	$i++;
    }
    print "\n";
}

close (IN);

	
