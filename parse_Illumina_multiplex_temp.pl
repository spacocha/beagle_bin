#! /usr/bin/perl
#
#

	die "Usage: <Solexa File1> <Solexa File2> <mapping> <output_prefix>\n" unless (@ARGV);
	($file1, $file2, $input, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($file2);
chomp ($input);
chomp ($output);

close (IN);

$/="@";
open (YRYR1, ">${output}.YRYR.1") or die "Can't open ${output}.YRYR.1\n";
open (YRYR2, ">${output}.YRYR.2") or die "Can't open ${output}.YRYR.2\n";
open (TGGTC1, ">${output}.TGGTC.1") or die "Can't open ${output}.TGGTC.1\n";
open (TGGTC2, ">${output}.TGGTC.2") or die "Can't open ${output}.TGGTC.1\n";
open (IN1, "<${file1}") or die "Can't open $file1\n";
open (IN2, "<${file2}") or die "Can't open $file2\n";
$first=1;
while ($line1=<IN1>){
    ($line2=<IN2>);
    if ($first){
	$first=();
    } else {
	chomp ($line1);
	chomp ($line2);
	next unless ($line1 && $line2);
	($header1, $sequence1, $useless1, $qual1)=split("\n", $line1);
	($header2, $sequence2, $useless2, $qual2)=split("\n", $line2);
	($bar1)=$header1=~/\#([A-z]{8})\/[0-9]/;
	($bar2)=$header2=~/\#([A-z]{8})\/[0-9]/;
	die "Funky $bar1 $header1 $bar2 $header2\n" unless ($bar1 eq $bar2);
	($forward1)=$sequence1=~/^(.{5})/;
	($reverse)=$sequence2=~/^(.{5})/;
	if ($sequence1=~/^TGGTC/){
            print TGGTC1 "@";
            print TGGTC1 "${header1}\n$sequence1\n$useless1\n$qual1\n";
            print TGGTC2 "@";
            print TGGTC2 "${header2}\n$sequence2\n$useless2\n$qual2\n";
	    
	}elsif ($sequence1=~/^[TC][AG][TC][AG]/){
	    print YRYR1 "@";
	    print YRYR1 "${header1}\n$sequence1\n$useless1\n$qual1\n";
	    print YRYR2 "@";
	    print YRYR2 "${header2}\n$sequence2\n$useless2\n$qual2\n";
	    
	}
    }
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
