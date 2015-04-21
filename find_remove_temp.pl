#! /usr/bin/perl -w

die "Use this for AdaptML to remove something
Usage: <file> > redirect\n" unless (@ARGV);
($file) = (@ARGV);
chomp ($file);


open (IN, "<$file" ) or die "Can't open $file\n";
while ($line =<IN>){
    chomp ($line);
    unless ($line=~/\.\.\.\.\.\.\.\.\.\./){
	$line =~ s/\.//g;
	print "$line\n";
    }
}
