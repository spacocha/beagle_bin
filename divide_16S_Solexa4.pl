#! /usr/bin/perl
#
#

	die "Usage: <Solexa File1> <True barcodes rc> <output_prefix>\n" unless (@ARGV);
	($file1, $barfile, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($barfile);
chomp ($output);

open (IN1, "<$barfile") or die "Can't open $barfile\n";
while ($line=<IN1>){
    chomp ($line);
    next unless ($line);
    ($lib, $rc_seq) = split ("\t", $line);
    $rc_seq=~s/ //g;#remove spaces
#    ($bar_rc) = revcomp();
    $barhash{$rc_seq}++;
    open ($rc_seq, ">${output}.${lib}_${rc_seq}") or die "Can't open ${output}.${lib}_${rc_seq}\n";
}
close (IN1);

$/="@";

open (IN2, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN2>){
		chomp ($line);
		next unless ($line);
		($header, $sequence, $useless1, $useless2)=split("\n", $line);
		#only keep sequences that have the exact bar code right at the beginning of 3rd read
		($barcode) = $header=~/^.+\#.*(.{7})\//;
		next unless ($barhash{$barcode});
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
