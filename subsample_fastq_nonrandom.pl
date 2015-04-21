#! /usr/bin/perl -w

die "Usage: fastq1 fastq2 every_x_line output\n" unless (@ARGV);
($fastq1, $fastq2, $lineno, $output) = (@ARGV);
chomp ($fastq1);
chomp ($fastq2);
chomp ($output);
chomp ($lineno);

$i=1;
open (IN, "<$fastq1" ) or die "Can't open $fastq1\n";
open (OUT, ">${output}.1") or die "Can't open ${output}.1\n";
while ($line1 =<IN>){
    ($line2=<IN>);
    ($line3=<IN>);
    ($line4=<IN>);
    chomp ($line1 ,$line2, $line3, $line4);
    next unless ($line1 && $line2 && $line3 && $line4);
    if ($i==$lineno){
	print OUT "$line1\n$line2\n$line3\n$line4\n";
	$i=1;
    } else {
	$i++;
    }
}
close(IN);
close (OUT);

$i=1;
open (IN, "<$fastq2" ) or die "Can't open $fastq2\n";
open (OUT, ">${output}.2") or die "Can't open ${output}.2\n";
while ($line1 =<IN>){
    ($line2=<IN>);
    ($line3=<IN>);
    ($line4=<IN>);
    chomp ($line1 ,$line2, $line3, $line4);
    next unless ($line1 && $line2 && $line3 && $line4);
    if ($i==$lineno){
        print OUT "$line1\n$line2\n$line3\n$line4\n";
        $i=1;
    } else {
        $i++;
    }
}
close(IN);
close (OUT);
