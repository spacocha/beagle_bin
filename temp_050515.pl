#! /usr/bin/perl -w

die "Usage: fasta1 > Redirect\n" unless (@ARGV);
($fasta1) = (@ARGV);
chomp ($fasta1);

open (IN1, "<$fasta1" ) or die "Can't open $fasta1\n";
$/=">";
while ($line1 =<IN1>){
    chomp ($line1);
    next unless ($line1);
    (@pieces)=split ("\n", $line1);
    ($header)=shift(@pieces);
    ($sequence)=join("", @pieces);
    ($shrthead)=$header=~/^(.+);size=/;
    print ">$shrthead\n$sequence\n";
}

close (IN1);


