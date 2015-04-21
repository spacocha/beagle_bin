#! /usr/bin/perl -w
#
#

	die "Use this program to add the FreClu groups to tab file
Usage: tab_file seq_col > Redirect\n" unless (@ARGV);
	($tab, $seqcol) = (@ARGV);

	die "Please follow command line args\n" unless ($seqcol);
chomp ($seqcol);
chomp ($tab);

$seqcolm1=$seqcol-1;

$count=1;
open (IN, "<$tab") or die "Can't open $tab\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces) = split ("\t", $line);
    foreach $piece (@pieces){
	print "$piece\t";
    }
    if ($hash{$pieces[$seqcolm1]}){
	#this sequence already has a cluster number
	print "$hash{$pieces[$seqcolm1]}\n";
    } elsif ($pieces[$seqcolm1]) {
	#make a new cluster number name
	(@pieces) = split ("", $count);
	$these = @pieces;
	$zerono = 7 - $these;
	$zerolet = "0";
	$zeros = $zerolet x $zerono;
	$name="SC"."${zeros}${count}"."P";
	$hash{$pieces[$seqcolm1]}=$name;
	print "$name\n";
	$count++;
    } else {
	die "No seqcol $seqcolm1 @pieces\n";
    }
}
close (IN);
