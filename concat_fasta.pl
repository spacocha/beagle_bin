#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: <input_file> header > Redirect output\n" unless (@ARGV);
	
	chomp (@ARGV);
	($file, $output) = (@ARGV);
	$/ = ">";
	open (IN, "<$file") or die "Can't open $file\n";
	while ($line1 = <IN>){	
		chomp ($line1);
		next unless ($line1);
		(@pieces) = split ("\n", $line1);
		($info) = shift (@pieces);
		($newsequence) = join ("", @pieces);
		$sequence="$sequence"."$newsequence";
		$sequence =~tr/\n//d;

	}
	
	close (IN);


(@splitseq)=$sequence=~/.{60}/g;
print ">$output\n";
foreach $seq (@splitseq){
    print "$seq\n";
}
