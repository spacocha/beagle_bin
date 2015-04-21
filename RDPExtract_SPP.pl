#! /usr/bin/perl -w
#
#

	die "Usage: File output\n" unless (@ARGV);
	($file, $outputtemp) = (@ARGV);

	die "Please follow command line args\n" unless ($file);
chomp ($file);
$count=1;
$\=">";

	open (IN, "<$file") or die "Can't open $file\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		
       	}
	close (IN);

open (OUT, ">${outputtemp}") or die "Can't open $outputtemp\n";
foreach $lnum (sort {$b <=> $a} keys %printhash){
        print OUT "$printhash{$lnum}";
}
print OUT "\n";
close (OUT);
	
