#! /usr/bin/perl -w

die "Usage: mat1 mat2 > redirect\n" unless (@ARGV);
($mat2, $mat1)=(@ARGV);
chomp ($mat1);
chomp ($mat2);
open (IN, "<$mat1" ) or die "Can't open $mat1\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    push (@{$hash{$OTU}}, @pieces);
}
close (IN);

open (IN, "<$mat2" ) or die "Can't open $mat2\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    print "$OTU";
    foreach $piece (@pieces){
	print "\t$piece";
    }
    if (@{$hash{$OTU}}){
	foreach $newpiece (@{$hash{$OTU}}){
	    print "\t$newpiece";
	}
    } else {
	die "Missing hash{OTU} $OTU\n";
    }
    print "\n";
}
close (IN);

 
