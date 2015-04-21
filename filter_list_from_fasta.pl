#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "input a list and fasta file of representatives
This program will output only the list entries with reps in the fasta
Usage: <list_file> <fasta> > Redirect output\n" unless (@ARGV);
	
	chomp (@ARGV);
	($list, $file) = (@ARGV);
die "Please follow the command line args for filter_list_from_fasta.pl\n" unless ($file);


$/ = ">";
open (IN, "<$file") or die "Can't open $file\n";
while ($line1 = <IN>){	
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    $hash{$info}++;	
    }

close (IN);

$/="\n";
open (IN, "<$list") or die "Can't open $list\n";
while ($line1 = <IN>){
    chomp ($line1);
    next unless ($line1);
    ($OTU, @pieces) = split ("\t", $line1);
    if ($hash{$OTU}){
	print "$line1\n";
    }
}
close (IN);	
