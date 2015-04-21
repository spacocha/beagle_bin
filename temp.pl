#! /usr/bin/perl -w

die "Usage: fastq1 fastq2 output\n" unless (@ARGV);
($fastq1, $fastq2, $output) = (@ARGV);
chomp ($fastq1, $fastq2);

open (IN1, "<$fastq1" ) or die "Can't open $fastq1\n";
open (IN2, "<${fastq2}") or die "Can't open $fastq2\n";

open (OUT1, ">${output}.for.fastq") or die "Can't open ${output}.for.fastq\n";
open (OUT2, ">${output}.rev.fastq") or die "Can't open ${output}.rev.fastq\n";

$/="@";
while ($line1 =<IN1>){
    $line2 = <IN2>;
    chomp ($line1, $line2);
    next unless ($line1 && $line2);
    ($header1)=split ("\n", $line1);
    ($header2)=split ("\n", $line2);
    ($test1)=$header1=~/^(.+)\/[0-9]/;
    ($test2)=$header2=~/^(.+)\/[0-9]/;
    until ($test1 eq $test2){
	$line2 = <IN2>;
	chomp ($line2);
	next unless ($line2);
	($header2)=split ("\n", $line2);
	($test2)=$header2=~/^(.+)\/[0-9]/;
    }
    print OUT1 "\@${line1}";
    print OUT2 "\@${line2}";
}

close (IN1);
close (IN2);
close (OUT1);
close (OUT2);


