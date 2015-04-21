#! /usr/bin/perl -w

die "Usage: log mat output\n" unless (@ARGV);
($log, $mat) = (@ARGV);
chomp ($log, $mat);
open (IN, "<${mat}") or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/mix/);
    (@pieces)=split("\t",$line);
    ($ID)=shift(@pieces);
    $total=0;
    foreach $piece (@pieces){
	$total+=$piece;
    }
    $hash{$ID}=$line;
    $totalhash{$ID}=$total;
}

close (IN);

open (IN, "<$log") or die "Can't open $log\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line=~/pvalue.*: ID.+M ID.+M .+/ || $line=~/Recording pvalue for ID.+M ID.+M .+/); 
    if ($line=~/calc/ || $line=~/Recording/){
	$calc++;
	$method="Calc";
	if ($line=~/Recording pvalue for ID.+M ID.+M .+/){
	    ($id1, $id2, $pvalue)=$line=~/Recording pvalue for (ID.+M) (ID.+M) (.+)/;
	} else {
	    ($id1, $id2, $pvalue)=$line=~/pvalue.*: (ID.+M) (ID.+M) (.+)$/; 
	}
	die "pvalue $pvalue\n$line\n" if ($pvalue=~/ID/);
	next unless ($id1, $id2);
	next if ($done{$id1}{$id2}{$method});
	print "$pvalue\t$method\n$hash{$id1}\n$hash{$id2}\n";
	$done{$id1}{$id2}{$method}++;
	$done{$id2}{$id1}{$method}++;
    }
}

