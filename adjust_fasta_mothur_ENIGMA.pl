#! /usr/bin/perl
#
#

	die "This will make the oligo files from the fasta file
Usage: <fasta> <qual> <oligos with barcode> <output>\n" unless (@ARGV);
	($file1, $file2,  $input, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($file2);
chomp ($input);
chomp ($output);


$/=">";

open (IN, "<${file1}") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    ($name, @seqs) = split ("\n", $line);
    #make a check of the forward barcode seq
    ($lib)=$name=~/--(.+)$/;
    $hash{$lib}++;
    #create a barcode
    
}
close (IN);


open (IN1, "<${file1}") or die "Can't open $file1\n";
open (FA, ">${output}.fasta") or die "Can't open ${output}.fasta\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($header1, @seqs)=split("\n", $line1);
    ($sequence)=join ("", @seqs);
    ($barseq)=$header1=~/\#.*([A-z]{7})\/[0-9]+$/;
    if ($hash{$barseq}){
	print FA ">$header1\n${barseq}"."CACAGTGCCAGCAGCCGCGGAAA"."${sequence}\n";
    } else {
	print FA ">$header1\nAAAAAAACACAGTGCCAGCAGCCGCGGAAA${sequence}\n";
    }
}
close (IN1);
close (FA);

open (IN1, "<${file2}") or die "Can't open $file2\n";
open (QUAL, ">${output}.qual") or die "Can't open ${output}.qual\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($header1, @seqs)=split("\n", $line1);
    print QUAL ">$header1\n60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 60 ";
    foreach $thing (@seqs){
	print QUAL "${thing}\n";
    }

}
close (IN1);
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
