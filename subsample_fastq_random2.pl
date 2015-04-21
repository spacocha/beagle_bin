#! /usr/bin/perl -w

die "Usage: fastq1 fastq2 range cutoff output\n" unless (@ARGV);
($fastq1, $fastq2, $range, $cutoff, $output) = (@ARGV);
chomp ($fastq1);
chomp ($fastq2);
chomp ($output);
chomp ($range);
chomp ($cutoff);

open (IN1, "<$fastq1" ) or die "Can't open $fastq1\n";
open (IN2, "<$fastq2") or die "Can't open $fastq2\n";
open (OUT1, ">${output}.1") or die "Can't open ${output}.1\n";
open (OUT2, ">${output}.2") or die "Can't open ${output}.2\n";
while ($line11 =<IN1>){
    ($line12=<IN1>);
    ($line13=<IN1>);
    ($line14=<IN1>);
    ($line21=<IN2>);
    ($line22=<IN2>);
    ($line23=<IN2>);
    ($line24=<IN2>);
    next unless ($line11 && $line12 && $line13 && $line14 && $line21 && $line22 && $line23 && $line24);
    ($compare)=rand($range);
    if ($compare >=$cutoff){
	print OUT1 "${line11}${line12}${line13}${line14}";
	print OUT2 "${line21}${line22}${line23}${line24}";
    }
}
close(IN1);
close (IN2);
close (OUT1);
close(OUT2);

