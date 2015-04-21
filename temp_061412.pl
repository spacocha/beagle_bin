#! /usr/bin/perl -w

die "Usage: bar file1 file2 > redirect\n" unless (@ARGV);

($barfile, $file1, $file2)=(@ARGV);
chomp ($barfile, $file1, $file2);

open (IN, "<$barfile" ) or die "Can't open $barfile\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($lib, $bar)=split ("\t", $line);
    $barhash{$bar}=$lib;
}
close (IN);
$/="@";
open (IN, "<$file1" ) or die "Can't open $file1\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name)=split ("\n", $line);
    ($bar)=$name=~/\#.+([ATCGN]{7})\/1/;
    die "Didn't get a bar $name\n" unless ($bar);
    if ($barhash{$bar}){
	$hash{$file1}{$barhash{$bar}}++;
	$total{$barhash{$bar}}++;
    }
}
close (IN);

open (IN, "<$file2" ) or die "Can't open $file2\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name)=split ("\n", $line);
    ($bar)=$name=~/\#.+([ATCGN]{7})\/1/;
    die "Didn't get a bar $name\n" unless ($bar);
    if ($barhash{$bar}){
	$hash{$file2}{$barhash{$bar}}++;
	$total{$barhash{$bar}}++;
    }
}
close (IN);
print "Lib\t$file1\t$file2\n";
foreach $bar (sort keys %barhash){
    $lib=$barhash{$bar};
    if ($total{$lib}){
	$sum=0;
	foreach $f (sort keys %hash){
	    $sum+=$hash{$f}{$lib};
	}
	die "Doesn't metch $lib\n" unless ($sum == $total{$lib});
	$f1=($hash{$file1}{$lib})/$sum;
	$f2=($hash{$file2}{$lib})/$sum;
	print "$lib\t$f1\t$f2\n";
    } else {
	print "$lib\t0\t0\n";
    }
}
