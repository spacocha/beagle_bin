#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "input a list and fasta file and this program will only output the first sequences of each line in the list
Usage: <list_file> <fasta> > Redirect output\n" unless (@ARGV);
	
	chomp (@ARGV);
	($list, $file) = (@ARGV);
die "Please follow the command line args for list2fasta.pl\n" unless ($file);

open (IN, "<$list") or die "Can't open $list\n";
while ($line1 = <IN>){
    chomp ($line1);
    next unless ($line1);
    ($OTU, @pieces) = split ("\t", $line1);
    $hash{$OTU}++;
}
close (IN);

$/ = ">";
open (IN, "<$file") or die "Can't open $file\n";
while ($line1 = <IN>){	
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    next unless ($hash{$info});
    print ">$info\n";
    ($sequence) = join ("", @pieces);
    $sequence =~tr/\n//d;
    print "$sequence\n"
	
    }

close (IN);

	
