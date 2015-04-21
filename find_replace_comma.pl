#! /usr/bin/perl -w

die "Use this for AdaptML to change 0.000000 to 0.000001
Usage: file with 0s > redirect" unless (@ARGV);
($file) = (@ARGV);
chomp ($file);

open (IN, "<$file" ) or die "Can't open $file\n";
while ($line =<IN>){
    chomp ($line);
    $line =~ s/,/\t/g;
    print "$line\n";
}
