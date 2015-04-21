#! /usr/bin/perl
#
#

	die "Usage: <fasta> <fake qual> <oligos with barcode> <output>\n" unless (@ARGV);
	($file1, $file2,  $input, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($file2);
chomp ($input);
chomp ($output);

open (IN, "<${input}") or die "Can't open $input\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line=~/barcode/);
    ($type, $barseq, $outname) = split ("\t", $line);
    #make a check of the forward barcode seq
    $hash{$outname}=$barseq;
}
close (IN);

$/=">";

open (IN1, "<${file1}") or die "Can't open $file1\n";
open (FA, ">${output}.fasta") or die "Can't open ${output}.fasta\n";
open (QUAL, ">${output}.qual") or die "Can't open ${output}.qual\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($header1, @seqs)=split("\n", $line1);
    ($sequence)=join ("", @seqs);
    ($outname)=$header1=~/^(mix[0-9])_/;
    if ($hash{$outname}){
	print FA ">$header1\n${hash{$outname}}CACAGTGCCAGCAGCCGCGGAAA${sequence}\n";
    } else {
        print FA ">$header1\nAAAAAAACACAGTGCCAGCAGCCGCGGAAA${sequence}\n";
    }

    print QUAL ">$header1\n60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60\n"
}
close (IN1);
close (FA);
close (QUAL);

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
		die "What is this (reverse complement): $pieces[$j] $rc_seq\n";
	    }
	} else {
	    die "NO j $j\n";
	}
	$j--;
    }
    return ($seq);
}
