#! /usr/bin/perl -w
#
#

	die "Use this program to add the ID groups to tab file
Usage: fasta  tab_file seqcol> Redirect\n" unless (@ARGV);
	($fasta, $tab, $seqcol) = (@ARGV);

	die "Please follow command line args\n" unless ($tab);
chomp ($fasta);
chomp ($tab);
chomp ($seqcol);
$seqcolm1=$seqcol-1;
$/=">";
open (IN, "<$fasta") or die "Can't open $fasta\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @seqs) = split ("\n", $line);
    $sequence=join ("", @seqs);
    $sequence=~s/ //g;
    $hash{$sequence}=$name;
}
close (IN);
#fix it so that only the upper level parents are represented as "parents"
$/="\n";

open (IN, "<$tab") or die "Can't open $tab\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    $first=1;
    foreach $piece (@pieces){
	if ($first){
	    print "$piece";
	    $first=();
	} else {
	    print "\t$piece";
	}
    }
    if ($hash{$pieces[$seqcolm1]}){
	print "\t$hash{$pieces[$seqcolm1]}\n";
    } else {
	print "\tremoved\n";
    }
	
}
close (IN);

