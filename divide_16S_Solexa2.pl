#! /usr/bin/perl
#
#

	die "Usage: <Solexa File1> <True barcodes> <output_prefix>\n" unless (@ARGV);
	($file1, $barfile, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($barfile);
chomp ($output);

open (IN1, "<$barfile") or die "Can't open $barfile\n";
while ($line=<IN1>){
    chomp ($line);
    next unless ($line);
    $rc_seq = $line;
    ($bar_rc) = revcomp();
    $barhash{$bar_rc}++;
    open ($bar_rc, ">${output}.${bar_rc}") or die "Can't open ${output}.${bar_rc}\n";
}
close (IN1);

$/="@";

open (IN2, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN2>){
		chomp ($line);
		next unless ($line);
		($header, $sequence, $useless1, $useless2)=split("\n", $line);
		($barcode) = $header=~/^.+\#(.{7})\//;
		next unless ($barhash{$barcode});
		($shrt_head) = $header =~/^(.+\#.{7})\/1$/;
		print $barcode "\@${line}";

	    }
	close (IN2);
foreach $bar (keys %barhash){
    close ($bar);
}

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
