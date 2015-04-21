#! /usr/bin/perl -w

die "Usage: <file> > redirect" unless (@ARGV);
($file) = (@ARGV);
chomp ($file);

open (IN, "<$file" ) or die "Can't open $file\n";
while ($line =<IN>){
    chomp ($line);
    $hash{$line}++;
    
}
foreach $line (keys %hash){
    print "$line\n";
}
