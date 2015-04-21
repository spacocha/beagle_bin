#! /usr/bin/perl -w

die "Use this for AdaptML to change something (find) to something else (replace)
Usage: <file> > redirect" unless (@ARGV);
($file) = (@ARGV);
chomp ($file);

open (IN, "<$file" ) or die "Can't open $file\n";
while ($line =<IN>){
    chomp ($line);
    ($lib, $bar) = $line=~/^(.+)_([ATGC]{7})$/;
    print "$lib,$bar\n";
}
