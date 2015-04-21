#! /usr/bin/perl -w

die "Usage: fasta1 fasta2 > redirect\n" unless (@ARGV);

($fasta1, $fasta2) = (@ARGV);
chomp ($fasta1);
chomp ($fasta2);
$/=">";
open (IN, "<$fasta1" ) or die "Can't open $fasta1\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\n", $line);
    ($shrtOTU)=$OTU=~/^(.+?) ./;
    if ($hash{$shrtOTU}){
	die "Duplicated name $shrtOTU $OTU $hash{$shrtOTU}\n";
    } else {
	$hash{$shrtOTU}=$OTU;
    }

}
close (IN);

open (IN, "<$fasta2" ) or die "Can't open $fasta2\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\n", $line);
    ($sequence)=join ("", @pieces);
    if ($hash{$OTU}){
	print ">$hash{$OTU}\n$sequence\n";
    } else {
	die "Missing name $OTU\n";
    }
}
close (IN);

