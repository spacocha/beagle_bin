#! /usr/bin/perl -w

die "Usage: ab.fa search_term> redirect\n" unless (@ARGV);
($ab, $search) = (@ARGV);
chomp ($ab);
chomp ($search);

$/=">";
open (IN, "<$ab" ) or die "Can't open $ab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, $mock)=split ("\n", $line);
    if ($info=~/${search}/){
	print ">$info\n$mock\n";
    }
}

close (IN);

