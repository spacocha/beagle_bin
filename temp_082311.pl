#! /usr/bin/perl -w

die "Usage: tab\n" unless (@ARGV);
($new) = (@ARGV);
chomp ($new);

print "#SampleID\tBarcodeSequence\tLinkerPrimerSequence\tTreatment\tDOB\tDescription\n";
open (IN, "<$new" ) or die "Can't open $new\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, $bar1, $bar2, $bar3) = split ("\t", $line);
    print "$info\t$bar1\tYATGCTGCCTCCCGTAGGAGT\tFast\t20080116\tFasting_mouse_I.D._636
$info\t$bar2\tYATGCTGCCTCCCGTAGGAGT\tFast\t20080116\tFasting_mouse_I.D._636
$info\t$bar3\tYATGCTGCCTCCCGTAGGAGT\tFast\t20080116\tFasting_mouse_I.D._636\n";
} 
close (IN);

