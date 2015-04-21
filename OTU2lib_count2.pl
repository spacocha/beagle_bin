#! /usr/bin/perl -w
#
#

	die "Use this program to take the tab file and make a matrix with the library counts
Usage: tab_file OTU1trans OTU2trans OTU3trans> Redirect\n" unless (@ARGV);
	($file2, $OTU1, $OTU2) = (@ARGV);
	die "Please follow command line args\n" unless ($OTU1);
chomp ($file2);
chomp ($OTU1);
chomp ($OTU2);

open (IN, "<${OTU2}") or die "Can't open ${OTU2}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    #remove if it was removed at any step of the process                                                                                                                          
    next if ($line=~/remove/);
    ($OTUF1, $OTUF2)=split ("\t", $line);
    $trans2hash{$OTUF1}=$OTUF2;
}
close (IN);

open (IN, "<${OTU1}") or die "Can't open ${OTU1}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    #remove if it was removed at any step of the process
    next if ($line=~/remove/);
    ($name, $OTUF1)=split ("\t", $line);
    $trans1hash{$name}=$OTUF1;
}
close (IN);

## Read in data file
open (IN, "<${file2}") or die "Can't open ${file2}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    #remove if it was removed at any step of the process
    ($name, $lib, @pieces) = split ("\t", $line);
    next unless ($name && $lib);
    $libhash{$name}=$lib;
    if ($trans1hash{$name}){
	if ($trans2hash{$trans1hash{$name}}){
	    $libcount{$trans2hash{$trans1hash{$name}}}{$lib}++;
	    $alllibcount{$lib}++;
	}
    }
}
close (IN);
print "#OTU";
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
