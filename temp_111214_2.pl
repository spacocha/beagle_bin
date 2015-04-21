#! /usr/bin/perl -w

die "Usage: file > redirect\n" unless (@ARGV);
($file1) = (@ARGV);
chomp ($file1);

open (IN1, "<${file1}") or die "Can't open $file1\n";
while ($line1 =<IN1>){
    chomp ($line1);
    next unless ($line1);
    $hash{$line1}++;
}

close (IN1);

foreach $entry (keys %hash){
    print "$entry\n";
}

