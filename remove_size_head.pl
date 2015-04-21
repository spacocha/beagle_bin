#! /usr/bin/perl -w

die "Usage: fasta > redirect\n" unless (@ARGV);
($fasta) = (@ARGV);
chomp ($fasta);

open (IN1, "<$fasta" ) or die "Can't open $fasta\n";

$/=">";
while ($line1 =<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($info, @pieces)=split ("\n", $line1);
    ($sequence)=join("", @pieces);
    $sequence =~tr/\n//d;
    if ($info=~/^.+;size=/){
	($newinfo)=$info=~/^(.+);size=/;
	print ">$newinfo\n$sequence\n";
    } else {
	die "Looking for ;size= but can't find it $info\n";
    }
}

close (IN1);


