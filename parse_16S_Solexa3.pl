#! /usr/bin/perl
#
#

	die "Usage: <Solexa File1> <Solexa file2> <True barcodes> <output name>\n" unless (@ARGV);
	($file1, $file2, $barfile, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($file2);
chomp ($barfile);
chomp ($output);

open (IN1, "<$barfile") or die "Can't open $barfile\n";
while ($line=<IN1>){
    chomp ($line);
    next unless ($line);
    $rc_seq = $line;
    ($bar_rc) = revcomp();
    $barhash{$bar_rc}++;
}
close (IN1);

$/="@";
$count=1;
$lnum=1;
open (IN2, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN2>){
		chomp ($line);
		next unless ($line);
		($header, $sequence, $useless1, $useless2)=split("\n", $line);
		($barcode) = $header=~/^.+\#(.{7})\//;
		next unless ($barhash{$barcode});
		($shrt_head) = $header =~/^(.+\#.{7})\/1$/;
		$hash1{$shrt_head}=$sequence;
	       	}
	close (IN2);

open (IN3, "<$file2") or die "Can't open $file2\n";
while ($line=<IN3>){
    chomp ($line);
    next unless ($line);
    ($header, $sequence, $useless1, $useless2)=split("\n", $line);
    ($barcode) = $header=~/^.+\#(.{7})\//;
    next unless ($barhash{$barcode});
    ($shrt_head) = $header =~/^(.+\#.{7})\/2$/;
    if ($hash1{$shrt_head}){
	open (OUT, ">>${output}.${barcode}") or die "Can't open ${output}.${barcode}\n";
        ($rc_seq) = $sequence=~/^([A-z]{92})/;
        ($seq2_rc) = revcomp();
        $total16S = "gtgccagcMgccgcggtaa"."$hash1{$shrt_head}"."$seq2_rc"."TGACGG";
        print OUT ">$shrt_head\n$total16S\n\n";
	close (OUT);
    }
}
close (IN3);


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
