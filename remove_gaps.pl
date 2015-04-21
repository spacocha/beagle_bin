#! /usr/bin/perl -w

die "Usage: fasta > redirect\n" unless (@ARGV);
($fasta)=(@ARGV);
$/=">";
chomp ($fasta);
open (IN, "<$fasta" ) or die "Can't open $fasta\n";
while ($line =<IN>){
	chomp ($line);
	next unless ($line);
	($OTU, @pieces)=split ("\n", $line);
	($sequence)=join ("", @pieces);
	$sequence=~s/-//g;
	$sequence=~s/\.//g;
	print ">$OTU\n$sequence\n";
}
close (IN);
