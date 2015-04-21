#! /usr/bin/perl
#
#

	die "This will make the oligo files from the fasta file
Usage: <fasta> <oligos with barcode> <output>\n" unless (@ARGV);
	($file1,  $input, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($file2);
chomp ($input);
chomp ($output);


$/=">";
open (IN, "<${file1}") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @seqs) = split ("\n", $line);
    #make a check of the forward barcode seq
    ($shrtname)=$name=~/^(.+?) /;
    ($lib)=$shrtname=~/^(.+)_/;
    unless ($hash{$lib}){
	#create a barcode
	$done=();
	until ($done){
	    $i=0;
	    $j=4;
	    $string="A";
	    until ($i >=$j){
		($nextbase)=rand_base();
		$string="$string"."$nextbase";
		$i++;
	    }
	    $done++ unless ($barhash{$string});
	}
	$barhash{$string}=$lib;
	$hash{$lib}=$string;
    }
}
close (IN);


open (IN1, "<${file1}") or die "Can't open $file1\n";
open (FA, ">${output}.fasta") or die "Can't open ${output}.fasta\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($header1, @seqs)=split("\n", $line1);
    ($shrtname)=$header1=~/^(.+?) /;
    ($lib)=$shrtname=~/^(.+)_/;
    ($sequence)=join ("", @seqs);
    if ($hash{$lib}){
	print FA ">$header1\n${hash{$lib}}"."${sequence}\n";
    }
}
close (IN1);
close (FA);

open (OUT, ">${input}") or die "Can't open ${input}\n";
foreach $lib (sort keys %hash){
    print OUT "barcode\t$hash{$lib}\t$lib\n";
}
close (OUT);

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

sub rand_base{
    my($got);
    my($random);
    my($four);
    $four=4;
    @randbase= ("A", "T", "C", "G");
    $got=0;
    until ($got){
	($random)=int(rand($four));
	$got++ if ($randbase[$random]);
    }
    return ($randbase[$random]);
	
}
