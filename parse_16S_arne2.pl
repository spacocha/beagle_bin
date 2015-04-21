#! /usr/bin/perl
#
#

	die "Usage: <Solexa File> > output\n" unless (@ARGV);
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
		next if ($barcode=~/TCTGTAT/);
		next if($barcode=~/GCGGTAG/);
		next if ($barcode=~/CCCGTAC/);
		next if($barcode=~/ACAGTAA/);
		$hash{$barcode}{$sequence}++;
		$tab{$barcode}++;
	}
	close (IN);

foreach $bar (keys %hash){
    next unless ($tab{$bar} > 1000);
    foreach $seq (sort {$hash{$bar}{$b} <=> $hash{$bar}{$a}} keys %{$hash{$bar}}){
	print "$bar\t$seq\t$hash{$bar}{$seq}\n";
    }
}

