#! /usr/bin/perl -w

die "Usage: tab fastq > redirect\n" unless (@ARGV);
($tab, $fastq) = (@ARGV);
chomp ($tab);
chomp ($fastq);

open (IN, "<$tab" ) or die "Can't open $tab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, $piece)=split ("\t", $line);
    ($shrtOTU)=$OTU=~/^(.+)\/[0-9]+/;
    $hash{$shrtOTU}=$piece;
}
close (IN);

$/="@";
open (IN, "<$fastq" ) or die "Can't open $fastq\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, $seq, $OTU2, $qual)=split ("\n", $line);
    ($shrtOTU)=$OTU=~/^(.+)\/[0-9]+/;
    if ($hash{$shrtOTU}){
	print "\@$OTU\n$seq\n+$OTU\n$qual\n";
    }
}
close (IN);
