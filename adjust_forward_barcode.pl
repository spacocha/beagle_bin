#! /usr/bin/perl
#
#

	die "Usage: Solexa_File1 Solexa_File2 bps output_prefix\n" unless (@ARGV);
	($file1, $file2, $bp, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($file2);
chomp ($bp);
chomp ($output);

open (IN1, "<${file1}") or die "Can't open $file1\n";
open (IN2, "<${file2}") or die "Can't open $file2\n";
open (OUT1, ">${output}.1") or die "Can't open $output.1\n";
open (OUT2, ">${output}.2") or die "Can't open $output.2\n";
$first=1;
while ($header1=<IN1>){
    ($sequence1=<IN1>);
    ($useless1=<IN1>);
    ($qual1=<IN1>);
    ($header2=<IN2>);
    ($sequence2=<IN2>);
    ($useless2=<IN2>);
    ($qual2=<IN2>);
    chomp ($header1, $sequence1, $useless1, $qual1);
    chomp ($header2, $sequence2, $useless2, $qual2);
    ($bar1)=$header1=~/\#([A-z]+)\/[0-9]/;
    ($bar2)=$header2=~/\#([A-z]+)\/[0-9]/;
    die "Funky 1.) $bar1 $header1 2.) $bar2 $header2\n" unless ($bar1 eq $bar2);
    ($forward1)=$sequence1=~/^(.{$bp})/;
    ($reverse)=$sequence2=~/^(.{$bp})/;
    $header1=~s/${bar1}/${bar1}${forward1}/;
    $header2=~s/${bar2}/${bar2}${forward1}/;
    $useless1=~s/${bar1}/${bar1}${forward1}/;
    $useless2=~s/${bar2}/${bar2}${forward1}/;
    print OUT1 "${header1}\n$sequence1\n$useless1\n$qual1\n";
    print OUT2 "${header2}\n$sequence2\n$useless2\n$qual2\n";

}
close (IN1);
close (IN2);


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
