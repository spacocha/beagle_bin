 #! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: <fasta> > redirect\n" unless (@ARGV);
	
($file) = (@ARGV);
die "Please follow command line args\n" unless ($file);
chomp ($file);
$/ = ">";
open (IN, "<$file") or die "Can't open $file\n";
while ($line1 = <IN>){	
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    ($sequence) = join ("", @pieces);
    $sequence =~tr/\n//d;
    (@bases)=split ("", $sequence);
    $len=@bases;
    die "$line1\n$len\n" unless ($len=~/[0-9]/);
    $histogram{$len}++;
}
close (IN);

foreach $len (sort {$a <=> $b} %histogram){
    print "${len}\t$histogram{$len}\n";
}
