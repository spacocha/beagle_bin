#! /usr/bin/perl -w

die "Usage: solexa map\n" unless (@ARGV);
($fasta1, $map) = (@ARGV);
chomp ($fasta1);
chomp($map);

open (IN, "<$map" ) or die "Can't open $map\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($libname, $bar, $link)=split ("\t", $line);
    ($bar2)=$link=~/^(.....)/;
    $barhash{$bar}++;
    $linkhash{$bar2}++;
    $mapping{$bar}{$bar2}++;
}
close (IN);

$/="@";
open (IN, "<$fasta1" ) or die "Can't open $fasta1\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($newline, $seq, $new2, $qual)=split ("\n", $line);
    ($bar)=$newline=~/\#([A-z]{7})\/1/;
    $error=();
    if ($seq=~/^(.....)GTGCCAG/){
	($link)=$seq=~/^(.....)/;
	$error="missing link" unless ($linkhash{$link});
    } elsif ($seq=~/.+GTGCCAG/) {
	($link)=$seq=~/^(.+)GTGCCAG/;
	if ($linkhash{$link}){
	    $error="length";
	} else {
	    $error="missing link and length";
	}
    } else {
	($link)=$seq=~/^(.....)/;
	if ($linkhash{$link}){
	    $error="primer";
	} else {
	    $error="missing link and primer";
	}
    }
    if ($mapping{$bar}{$link}){
	$ok{$bar}{$link}++;
    } elsif ($barhash{$bar} && $linkhash{$link}){
	$bad{$bar}{$link}++;
    } elsif ($error) {
	$errorhash{$error}++;
    } else {
	if ($barhash{$bar}){
	    $errorhash{"other"}++;
	} else {
	    $errorhash{"missing bar"}++;
	}
    }
}
close (IN);


foreach $bar (sort keys %ok){
    foreach $link (sort keys %{$ok{$bar}}){
	print "OK: $bar\t$link\t$ok{$bar}{$link}\n";
    }
}
foreach $bar (sort keys %bad){
    foreach $link (sort keys %{$bad{$bar}}){
	print "BAD: $bar\t$link\t$bad{$bar}{$link}\n";
    }
}
foreach $error (sort keys %errorhash){
    print "Error: $error $errorhash{$error}\n";
}
