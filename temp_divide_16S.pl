#! /usr/bin/perl
#
#

	die "Use this file to divide your entire library into barcodes-specific files
Dividing barcodes will make the downstream processing faster and easier, especially on a cluster
For the last option, say yes or no if your barcodes are in the reverse complement
Usage: <Solexa File> <barfile> <output_prefix> <dist_cutoff>\n" unless (@ARGV);
	($file1, $barfile, $output, $cutoff) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($barfile);
chomp ($output);
chomp ($cutoff);

open (IN2, "<$barfile") or die "Can't open $barfile\n";
while ($line=<IN2>){
    chomp ($line);
    next unless ($line);
    ($lib, $rc_seq)= split ("\t", $line);
    $rc_seq=~s/ //g;
    next unless ($rc_seq);
    ($rcbar) = revcomp ();
    $libhash{$rcbar}=$lib;
}
close (IN2);

$/="@";

open (IN2, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN2>){
		chomp ($line);
		next unless ($line);
		($header, $sequence, $useless1, $useless2)=split("\n", $line);
		$totalreads++;
		#only keep sequences that have the exact bar code right at the beginning of 3rd read
		($barcode) = $header=~/^.+\#.*(.{7})\//;
		$bartotalhash{$barcode}++;
	    }
	close (IN2);
foreach $bar (keys %bartotalhash){
    if ($bartotalhash{$bar} > $cutoff){
	if ($libhash{$bar}){
	    $lib = $libhash{$bar};
	    open ($bar, ">${output}.${lib}_${bar}") or die "Can't open ${output}.${lib}_${bar}\n";
	    $closehash{$bar}++;
	} else {
	    $libcount++;
	    $lib = "LIB"."$libcount";
            open ($bar, ">${output}.${lib}_${bar}") or die "Can't open ${output}.${lib}_${bar}\n";
            $closehash{$bar}++;

	}
    }
}
open (IN2, "<$file1") or die "Can't open $file1\n";
while ($line=<IN2>){
    chomp ($line);
    next unless ($line);
    ($header, $sequence, $useless1, $useless2)=split("\n", $line);
    $totalreads++;                #only keep sequences that have the exact bar code right at the beginning of 3rd read                                                                              
    ($barcode) = $header=~/^.+\#.*(.{7})\//;
    if ($closehash{$barcode}){
	print $barcode "\@$header\n$sequence\n$useless1\n$useless2\n";
    }
}
close (IN2);


foreach $bar (keys %closehash){
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
		die "RC NO Piece: $pieces[$j]\n";
	    }
	} else {
	    die "NO j $j\n";
	}
	$j--;
    }
    return ($seq);
}
