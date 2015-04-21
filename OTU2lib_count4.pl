#! /usr/bin/perl -w
#
#

	die "Use this program to take the tab file and make a matrix with the library counts
Usage: tab OTU.trans> Redirect\n" unless (@ARGV);
	($tab, $OTU2t) = (@ARGV);
	die "Please follow command line args\n" unless ($OTU2t);
chomp ($tab);
chomp ($OTU2t);


open (IN, "<${OTU2t}") or die "Can't open ${OTU2t}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    #remove if it was removed at any step of the process                                                                                                                          
    next if ($line=~/remove/);
    ($OTUF1, $OTUF2)=split ("\t", $line);
    $trans2hash{$OTUF1}=$OTUF2;
}
close (IN);

open (IN, "<${tab}") or die "Can't open ${tab}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    #remove if it was removed at any step of the process
    next if ($line=~/remove/);
    ($name, $lib)=split ("\t", $line);
    if ($trans2hash{$name}){
	$libcount{$trans2hash{$name}}{$lib}++;
	$alllibcount{$lib}++;
    }
}
close (IN);

print "OTU";
foreach $lib (sort keys %alllibcount){
    print "\t$lib";
}
print "\n";

foreach $OTU (sort keys %libcount){
    print "$OTU";
    foreach $lib (sort keys %alllibcount){
	if ($libcount{$OTU}{$lib}){
	    print "\t$libcount{$OTU}{$lib}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}
