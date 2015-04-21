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
    ($first, $bar)=$info=~/^(.+)\#(.+)\/[0-9]$/;
    ($lcbar)=lc($bar);
    ($forbarcode)=$seq=~/^(.{5})/;
    ($lcforbar)=lc($forbarcode);
    ($concatbar)="$forbarcode"."$bar";
    ($concatqual)="$lcforbar"."$lcbar";
    print "\@${first}\#${bar}/3\n$concatbar\n+\n$concatqual\n";
} 
close (IN);

