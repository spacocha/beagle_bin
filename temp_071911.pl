#! /usr/bin/perl -w

die "Usage: new_file > redirect\n" unless (@ARGV);
($new) = (@ARGV);
chomp ($new);

open (IN, "<$new" ) or die "Can't open $new\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $seq)=split ("\t", $line);
    ($keeper)=$seq=~/^..(.......)/;
    print "$name\t$keeper\n";
} 
close (IN);

