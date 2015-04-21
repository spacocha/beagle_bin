#! /usr/bin/perl -w
#
#

	die "Use this program to take the tab file and make a matrix with the library counts
Usage: OTU1trans OTU2trans OTU2fa> Redirect\n" unless (@ARGV);
	($OTU1t, $OTU2t, $OTU2f) = (@ARGV);
	die "Please follow command line args\n" unless ($OTU2f);
chomp ($OTU1t);
chomp ($OTU2t);
chomp ($OTU2f);

print "Opening ${OTU2f}\n";
$/=">";
open (IN, "<${OTU2f}") or die "Can't open ${OTU2f}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($info, $seq)=split ("\n", $line);
    ($OTUF2, $abund)=$info=~/^(.+)_([0-9]+)$/;
    $OTU2abund{$OTUF2}=$abund if ($abund>10);
}
close (IN);

$/="\n";
print "Opening $OTU2t\n";
open (IN, "<${OTU2t}") or die "Can't open ${OTU2t}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    #remove if it was removed at any step of the process                                                                                                                          
    next if ($line=~/remove/);
    ($OTUF1, $OTUF2)=split ("\t", $line);
    $trans2hash{$OTUF1}=$OTUF2 if ($OTU2abund{$OTUF2});
}
close (IN);

print "Opening OTU1t\n";
open (IN, "<${OTU1t}") or die "Can't open ${OTU1t}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    #remove if it was removed at any step of the process
    next if ($line=~/remove/);
    ($name, $lib, $OTUF1)=split ("\t", $line);
    if ($trans2hash{$OTUF1}){
	$libcount{$trans2hash{$OTUF1}}{$lib}++;
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
