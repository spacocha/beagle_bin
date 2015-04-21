#! /usr/bin/perl
#
#

	die "Usage: \n" unless (@ARGV);
	($file1) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);

open (IN1, "<$file1") or die "Can't open $file1\n";
while ($line1=<IN1>){
    next unless ($line1);
    ($s, $q, $percent, $len, $mis, $gap, $sstart, $send, $qstart, $qend, $evalue, $bits)=split ("\t", $line1);
    ($coverage)=$send-$sstart+1;
    $frac=$coverage/75;
    if ($frac > 0.9){
	#only record the values that are above the threshold
	$hash{$s}=$q;
    } else {
	$hash{$s}="NA";
    }
}
close (IN1);

foreach $s (sort keys %hash){
    print "$s\t$hash{$s}\n";
}
