#! /usr/bin/perl
#
#

	die "Usage: mat list fasta> redirect\n" unless (@ARGV);
	($file1, $file2, $fasta) = (@ARGV);

	die "Please follow command line args\n" unless ($fasta);
chomp ($file1);
chomp ($file2);
chomp ($fasta);

$/=">";
open (IN, "<${fasta}") or die "Can't open $fasta\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @seqs)=split ("\n", $line);
    $sequence=join ("", @seqs);
    $seqhash{$name}=$sequence;
}
close (IN);
$/="\n";

open (IN1, "<$file1") or die "Can't open $file1\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($longname, @seqs)=split("\t", $line1);
    if (@headers){
	$total=();
	foreach $f (@seqs){
	    $total+=$f;
	}
	$hash{$longname}=$total;
    } else {
	@headers=@seqs;
    }
}
close (IN1);

$/="\n";
$first=1;
$type=();
open (IN1, "<$file2") or die "Can't open $file2\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    if ($type=~/[Qq]/){
	($parent, @rest)=split("\t", $line1);
    } else {
	(@rest)=split("\t", $line1);
    }
    #find the most abundant 
    $mostabund=0;
    $rep=();
    foreach $iso (@rest){
	if ($hash{$iso}){
	    if ($hash{$iso} >=$mostabund){
		$rep=$iso;
	    }
	}
    }
    if ($type=~/[Qq]/){
	print ">$parent\n$seqhash{$rep}\n";
    } else {
	print ">$rest[0]\n$seqhash{$rep}\n";
    }
}
close (IN1);
