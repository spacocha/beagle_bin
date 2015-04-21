#! /usr/bin/perl -w

die "Usage: fastq1 fastq2 line_no output\n" unless (@ARGV);
($fastq1, $fastq2, $lineno, $output) = (@ARGV);
chomp ($fastq1);
chomp ($fastq2);
chomp ($output);
chomp ($lineno);

open (IN, "<$fastq1" ) or die "Can't open $fastq1\n";
while ($line1 =<IN>){
    ($line2=<IN>);
    ($line3=<IN>);
    ($line4=<IN>);
    chomp ($line1 ,$line2, $line3, $line4);
    next unless ($line1 && $line2 && $line3 && $line4);
    $totalentries++;
}
close(IN);

#pick a random subset of entries
%linehash=();
$i=0;
until ($i >= $lineno){
    ($num)=int(rand($totalentries));
    #keep this rand number as an entry unless it was already picked
    unless ($linehash{$num}){
	$linehash{$num}++;
	$i++;
    }
}
    

open (IN, "<$fastq1" ) or die "Can't open $fastq1\n";
open (OUT, ">${output}.1") or die "Can't open ${output}.1\n";
$i=0;
while ($line1 =<IN>){
    ($line2=<IN>);
    ($line3=<IN>);
    ($line4=<IN>);
    chomp ($line1, $line2, $line3, $line4);
    next unless ($line1 && $line2 && $line3 && $line4);
    if ($linehash{$i}){
	print OUT "$line1\n$line2\n$line3\n$line4\n";
    }
    $i++;
}
close (IN);
close (OUT);

open (IN, "<$fastq2" ) or die "Can't open $fastq2\n";
open (OUT, ">${output}.2") or die "Can't open ${output}.2\n";
$i=0;
while ($line1 =<IN>){
    ($line2=<IN>);
    ($line3=<IN>);
    ($line4=<IN>);
    chomp ($line1, $line2, $line3, $line4); 
    next unless ($line1 && $line2 && $line3 && $line4);
    if ($linehash{$i}){
        print OUT "$line1\n$line2\n$line3\n$line4\n";
    }
    $i++;
}
close (IN);
close (OUT);
