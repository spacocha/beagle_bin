#! /usr/bin/perl -w

die "Usage: mapping fasta > Redicted\n" unless (@ARGV);
($map, $new) = (@ARGV);
chomp ($new);
chomp ($map);

$first=1;
open (IN, "<$map" ) or die "Can't open $map\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $barcode, @values)=split ("\t", $line);
    if ($first){
	$first=();
    } else {
	$rc_seq=$barcode;
	($revseq)=revcomp($rc_seq);
	$hash{$revseq}=$name;
    }
}
close (IN);

$/=">";

%namecount=();
open (IN, "<$new" ) or die "Can't open $new\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs) = split ("\n", $line);
    ($barseq)=$info=~/\#([A-z]{8})/;
    if ($hash{$barseq}){
	$namecount{$barseq}++;
	print ">$hash{$barseq}_${namecount{$barseq}} $info\n";
	foreach $seq (@seqs){
	    print "$seq";
	}
	print "\n";
    }
}
close (IN);

sub revcomp{
    (@pieces) = split ("", ${rc_seq});
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
		die "What is this (reverse complement): $pieces[$j] $rc_seq $j\n";
	    }
	} else {
	    die "NO j $j\n";
	}
	$j-=1;
    }
    return ($seq);
}
