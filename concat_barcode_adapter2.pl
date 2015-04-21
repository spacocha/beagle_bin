#! /usr/bin/perl
#
#

	die "Usage: barcodes >redirect\n" unless (@ARGV);
	($barfile) = (@ARGV);

	die "Please follow command line args\n" unless ($barfile);
chomp ($barfile);

open (IN1, "<$barfile") or die "Can't open $barfile\n";
while ($line=<IN1>){
    chomp ($line);
    next unless ($line);
    ($time, $name, $rc_seq) = split ("\t", $line);
    $rc_seq=~s/ //g;
    ($bar_rc) = revcomp();
    $reverse="CAAGCAGAAGACGGCATACGAGAT"."$bar_rc"."CGGTCTCGGCATTCCTGCTGAACCGCTCTTCCGATCT";
    $forward="AATGATACGGCGACCACCGAGATCT"."$bar_rc"."ACACTCTTTCCCTACACGACGCTCTTCCGATCT";
    print "$name\t$forward\t$bar_rc\t$reverse\t$bar_rc\n";
}
close (IN1);

sub revcomp{
    (@pieces) = split ("", $rc_seq);
    #make reverse complement
    $j = @pieces;
    $j-=1;
    $seq = ();
    until ($j < 0){
	if ($pieces[$j]){
	    if ($pieces[$j] eq "A"){
		$seq = "$seq"."T";
	    } elsif ($pieces[$j] eq "T"){
		$seq = "$seq"."A";
	    } elsif ($pieces[$j] eq "C"){
		$seq = "$seq"."G";
	    } elsif ($pieces[$j] eq "G"){
		$seq = "$seq"."C";
	    } elsif ($pieces[$j] eq "N"){
		$seq = "$seq"."N";
	    } else {
		die "$pieces[$j]\n";
	    }
	} else {
	    die "NO j $j\n";
	}
	$j--;
    }
    return ($seq);
}
