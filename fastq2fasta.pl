#! /usr/bin/perl -w

die "Usage: fastq\n" unless (@ARGV);
($new) = (@ARGV);
chomp ($new);

$/="@";
open (IN, "<$new" ) or die "Can't open $new\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, $seq, $info2, $qual) = split ("\n", $line);
    print ">$info\n$seq\n";
} 
close (IN);

