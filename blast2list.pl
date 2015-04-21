 #! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: blast > list\n" unless (@ARGV);
	
($file) = (@ARGV);
die "Please follow command line args\n" unless ($file);
chomp ($file);
open (IN, "<$file") or die "Can't open $file\n";
while ($line1 = <IN>){	
    chomp ($line1);
    next unless ($line1);
    ($unique, $blast) = split ("\t", $line1);
    $hash{$blast}{$unique}++;
}

foreach $blast (sort keys %hash){
    print "$blast";
    foreach $unique (sort keys %{$hash{$blast}}){
	print "\t$unique";
    }
    print "\n";
}

