#! /usr/bin/perl -w

die "Usage: map2mock1 map2mock2 concat.trans\n" unless (@ARGV);
($fasta1, $fasta2, $concat) = (@ARGV);
chomp ($fasta1);
chomp($fasta2);
chomp ($concat);

open (IN, "<$fasta1" ) or die "Can't open $fasta1\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($newline, $seq)=split ("\t", $line);
    ($OTU)=$newline=~/^(.+)_[0-9]+$/;
    $hash1{$OTU}=$seq;
}
close (IN);

open (IN, "<$fasta2" ) or die "Can't open $fasta2\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($newline, $seq)=split ("\t", $line);
    ($OTU)=$newline=~/^(.+)_[0-9]+$/;
    $hash2{$OTU}=$seq;
}
close (IN);

$/=">";
open (IN, "<$concat" ) or die "Can't open $concat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($newline, $seq)=split ("\n", $line);
    ($OTU1, $OTU2)=$newline=~/^(.+)_(.+)$/;
    if ($hash1{$OTU1}){
	if ($hash2{$OTU2}){
	    if ($hash1{$OTU1} eq $hash2{$OTU2}){
		print "$newline\t$hash1{$OTU1}\t$hash2{$OTU2}\tSame\n";
	    } else {
		print "$newline\t$hash1{$OTU1}\t$hash2{$OTU2}\tDifferent\n";
	    }
	} else {
	    print "$newline\t$hash1{$OTU1}\tNA\tMissing\n";
	}
    } elsif ($hash2{$OTU2}){
	print "$newline\tNA\t$hash2{$OTU2}\tMissing\n";
    } else {
	print "$newline\tNA\tNA\tMissing\n";
    }
}
close (IN);
