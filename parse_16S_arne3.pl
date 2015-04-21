#! /usr/bin/perl -w
#
#

	die "Usage: File output\n" unless (@ARGV);
	($file) = (@ARGV);

	die "Please follow command line args\n" unless ($file);
chomp ($file);
$/="@";
$count=1;
$lnum=1;
	open (IN, "<$file") or die "Can't open $file\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($header, $sequence, $useless1, $useless2)=split("\n", $line);
		($barcode) = $header=~/^.+\#(.{7})\//;
		unless ($barcode eq "TCTGTAT" || $barcode eq "GCGGTAG" || $barcode=~/N/){
		    $hash{$sequence}++;
		}
       	}
	close (IN);

foreach $seq (keys %hash){
    (@pieces)=split ("", $seq);
    $i = 0;
    $j = @pieces;
    until ($i >= $j){
	$positionhash{$i}{$pieces[$i]}++;
	$i++;
    }
}

foreach $position (sort {$a <=> $b} keys %positionhash){
    print "Position: $position";
    foreach $base (sort {$a <=> $b} keys %{$positionhash{$position}}){
	print "\t$base: $positionhash{$position}{$base}";
    }
    print "\n";
}

