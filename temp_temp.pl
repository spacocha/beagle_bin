#! /usr/bin/perl -w

die "Usage: file1 file2\n" unless (@ARGV);
($fastq1, $fastq2) = (@ARGV);
chomp ($fastq1, $fastq2);

open (IN1, "<$fastq1" ) or die "Can't open $fastq1\n";
while ($line1 =<IN1>){
    chomp ($line1);
    next unless ($line1);
    $hash1{$line1}++;
    $allhash{$line1}++;
}

close (IN1);
open (IN1, "<$fastq2" ) or die "Can't open $fastq2\n";
while ($line1 =<IN1>){
    chomp ($line1);
    next unless ($line1);
    $hash2{$line1}++;
    $allhash{$line1}++;
}

close (IN1);

foreach $entry (sort keys %allhash){
    print "$entry";
    if ($hash1{$entry}){
	print "\tIn $fastq1";
    } else {
	print "\tNot in $fastq1";
    }
    if ($hash2{$entry}){
	print "\tIn $fastq2\n";
    } else {
	print "\tNot in $fastq2\n";
    }
}
