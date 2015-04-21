#! /usr/bin/perl -w

die "Usage: rcplus > redirect\n" unless (@ARGV);

($rcplus)=(@ARGV);
chomp ($rcplus);
print "#SampleID\tBarcodeSequence\tLinkerPrimerSequence\tData\n";
open (IN, "<$rcplus" ) or die "Can't open $rcplus\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($lib, $truebar, @bars)=split ("\t", $line);
    print "$lib\t$truebar\tYRYRGTGCCAGCMGCCGCGGTAA\t$lib\n";
}
close (IN);

