#! /usr/bin/perl -w
#
#

	die "Use this program to add the ID groups to tab file
Usage: datatab  ref_tab_file seqcol> Redirect\n" unless (@ARGV);
	($datatab, $tab, $seqcol) = (@ARGV);

	die "Please follow command line args\n" unless ($tab);
chomp ($datatab);
chomp ($tab);
chomp ($seqcol);
$seqcolm1=$seqcol-1;

open (IN, "<$datatab") or die "Can't open $datatab\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $sequence) = split ("\t", $line);
    $hash{$name}=$sequence;
}
close (IN);
#fix it so that only the upper level parents are represented as "parents"

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

