#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Use this to put all fasta entries into a single list
Usage: <input_file> Redirect output\n" unless (@ARGV);
	
chomp (@ARGV);
($file) = (@ARGV);
$/ = ">";
open (IN, "<$file") or die "Can't open $file\n";
while ($line1 = <IN>){	
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    print "$info\t";
    
}
print "\n";
close (IN);

	
