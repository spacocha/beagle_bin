#! /usr/bin/perl -w

die "Usage: fastq > redirect\n" unless (@ARGV);

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
