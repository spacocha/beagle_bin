#! /usr/bin/perl -w

die "Use this to filter a list an make OTUs from the list
Usage: otulist > redirect\n" unless (@ARGV);

($otulist)=(@ARGV);
chomp ($otulist);

die "Please follow command line arg\n" unless ($otulist);

open (IN, "<$otulist" ) or die "Can't open $otulist\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($otunum, $groupline)=split ("\t", $line);
    (@groups)=split (",", $groupline);
    foreach $hit (@groups){
	($lib)=$hit=~/^(.+)_[0-9]+$/;
	$headers{$lib}++;
	die "What $hit\n" unless ($lib);
	$finalhash{$otunum}{$lib}++;
    }
}
close (IN);

print "OTU";
foreach $head (sort keys %headers){
    print "\t$head";
}
print "\n";

foreach $OTU (sort keys %finalhash){
    print "$OTU";
    foreach $head (sort keys %headers){
	if ($finalhash{$OTU}{$head}){
	    print "\t$finalhash{$OTU}{$head}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}
