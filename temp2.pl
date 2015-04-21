#! /usr/bin/perl -w

die "Usage: mats> redirect\n" unless (@ARGV);
chomp (@ARGV);

foreach $file (@ARGV){
    open (IN, "<$file" ) or die "Can't open $file\n";
    while ($line =<IN>){
	chomp ($line);
	next unless ($line);
	($OTU, @pieces)=split ("\t", $line);
	$hash{$file}{$OTU}=$line;
    }
    
    close (IN);
}

