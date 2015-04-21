#! /usr/bin/perl -w

die "Use this script to combine all error files into a list
The input should be a list of error files (created by ls *.err > error_list)
Usage: error_list > redirect\n" unless (@ARGV);
($error) = (@ARGV);
chomp ($error);
#make the pvalue hash to use later

#read in the error first with suggestions on which to merge
open (ERR, "<$error" ) or die "Can't open $error\n";
while ($errline =<ERR>){
    chomp ($errline);
    next unless ($errline);
    open (IN, "<${errline}") or die "Can't open in $errlinen\n";
    while ($line =<IN>){
	chomp ($line);
	next unless ($line);
	if ($line=~/^Changefrom,.+,.+,Changeto,/){
	    ($child, $parent) =$line=~/^Changefrom,(.+?),(.+?),Changeto,/;
	    $hash{$parent}{$child}++;
	    $childhash{$child}++;
	    $allhash{$child}++;
	}
	if ($line=~/is a parent$/){
	    ($ID)=$line=~/^(.+) is a parent$/;
	    $allhash{$ID}++;
	}
    }
    close (IN);
}
close (ERR);

foreach $OTU (sort keys %allhash){
    next if ($childhash{$OTU});
    print "$OTU";
    if (%{$hash{$parent}}){
	foreach $otherOTU (sort keys %{$hash{$OTU}}){
	    print "\t$otherOTU";
	}
    }
    print "\n";
}
