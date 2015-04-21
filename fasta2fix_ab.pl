#! /usr/bin/perl -w

die "Usage: fasta > Redicted\n" unless (@ARGV);
($new) = (@ARGV);
chomp ($new);

$/=">";

open (IN, "<$new" ) or die "Can't open $new\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs) = split ("\n", $line);
    if ($info=~/.+\/ab=[0-9]+\/*$/){
	($OTU)=$info=~/^(.+)\/ab=[0-9]+\/*$/;
	$seq=join ("", @seqs);
	print ">$OTU\n$seq\n";
    } else {
	die "Missing /ab=[0-9]+ at the end\n";
    } 
}
close (IN);

