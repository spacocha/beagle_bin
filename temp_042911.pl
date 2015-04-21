#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: mat fasta> Redirect output\n" unless (@ARGV);
	
	chomp (@ARGV);
	($mat, $file) = (@ARGV);
$/=">";
open (IN, "<$file") or die "Can't open $file\n";
while ($line1 = <IN>){
    chomp ($line1);
    next unless ($line1);
    ($info, @pieces) = split ("\n", $line1);
    $hash{$info}++;
}
close (IN);
	$/ = "\n";
	open (IN, "<$mat") or die "Can't open $mat\n";
	while ($line1 = <IN>){	
		chomp ($line1);
		next unless ($line1);
		(@pieces) = split ("\t", $line1);
		($info) = shift (@pieces);
		print "$info\n" unless ($hash{$info});

	}
	
	close (IN);

	
