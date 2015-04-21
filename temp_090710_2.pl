#! /usr/bin/perl -w
#
#

	die "Usage: UC2group_output UC_group > Redirect\n" unless (@ARGV);
	($file1, $group) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);

open (IN, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($UC, $name, $FreClu, $parent, $seq) = split ("\t", $line);
		if ($UC eq $group){
		    ($bar) = $name=~/([ACTG]{7})\/[12]$/;
		    $hash{$FreClu}{$bar}++;
		    $totalbar{$bar}++;
		}
       	}
close (IN);
print "FreClu parent";
foreach $bar (sort keys %totalbar){
    print "\t$bar";
}
print "\n";

foreach $FreClu (sort keys %hash){
    print "$FreClu";
    foreach $bar (sort keys %totalbar){
	if ($hash{$FreClu}{$bar}){
	    print "\t$hash{$FreClu}{$bar}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}
