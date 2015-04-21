#! /usr/bin/perl
#
#

	die "Usage: <Solexa File1>\n" unless (@ARGV);
	($file1) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);

$/="@";

open (IN2, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN2>){
		chomp ($line);
		next unless ($line);
		($header, $sequence, $useless1, $useless2)=split("\n", $line);
		#only keep sequences that have the exact bar code right at the beginning of 3rd read
		($barcode) = $header=~/^.+\#.*(.{7})\//;
		$hash{$barcode}++;
	    }
	close (IN2);
foreach $barcode (keys %hash){
    print "$barcode\t$hash{$barcode}\n";
}
