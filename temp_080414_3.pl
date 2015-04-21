#! /usr/bin/perl -w
#
#

die "Usage: blast1 blast2 > output\n" unless (@ARGV);
($blast1, $blast2) = (@ARGV);

die "Please follow command line args\n" unless ($blast2);
chomp ($blast1, $blast2);
open (IN, "<$blast1") or die "Can't open $blast1\n";
while ($line=<IN>){
    chomp ($line);
    ($OTU1, $OTU2, $id, $length, $mismatch, $gap, $s1, $e1, $s2, $e2, $bits, $evalue) = split ("\t", $line);
    $blast1hash{$OTU1}=$OTU2;
}
close (IN);

open (IN, "<$blast2") or die "Can't open $blast2\n";
while ($line=<IN>){
    chomp ($line);
    ($OTU1, $OTU2, $id, $length, $mismatch, $gap, $s1, $e1, $s2, $e2, $bits, $evalue) = split ("\t", $line);
    $blast2hash{$OTU1}=$OTU2;
}
close (IN);

foreach $OTU1 (sort keys %blast1hash){
    if ($blast2hash{$blast1hash{$OTU1}}){
	if ($blast2hash{$blast1hash{$OTU1}} eq $OTU1){
	    print "$OTU1\t$blast1hash{$OTU1}\n";
	    $done{$OTU1}{$blast1hash{$OTU1}}++;
	    $done{$blast1hash{$OTU1}}{$OTU1}++;
	} else {
	    print "$OTU1\tunique\t1\n";
	}
    }
}

foreach $OTU2 (sort keys %blast2hash){
    if ($blast1hash{$blast2hash{$OTU2}}){
	if ($blast1hash{$blast2hash{$OTU2}} eq $OTU2){
	    unless ($done{$OTU2}{$blast2hash{$OTU2}}){
		print "$blast2hash{$OTU2}\t$OTU2\n";
		$done{$OTU2}{$blast2hash{$OTU2}}++;
		$done{$blast2hash{$OTU2}}{$OTU2}++;
	    }
	} else {
	    print "unique\t$OTU2\t2\n";
	}
    }
}
