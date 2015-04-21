#! /usr/bin/perl -w

die "Use this program to determine the distribution of double barcodes in your fastq file
Any barcodes with less than 100 counts are filtered out
This assumes a barcode read in the info and the first 5 bases of the forward read are the barcodes
Usage: fastq > redirect\n" unless (@ARGV);

($fastq)=(@ARGV);
chomp ($fastq);

$/="@";
open (IN, "<$fastq" ) or die "Can't open $fastq\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, $seq, $info2, $qual)=split ("\n", $line);
    ($first, $bar)=$info=~/^(.+)\#(.+)\/[0-9]$/;
    ($lcbar)=lc($bar);
    ($forbarcode)=$seq=~/^(.{5})/;
    ($concatbar)="$forbarcode"."$bar";
    $hash{$concatbar}++;

}
close (IN);

foreach $bar (sort {$hash{$b} <=> $hash{$a}} keys %hash){
    if ($hash{$bar} > 100){
	print "$bar\t$hash{$bar}\n";
    }
}
