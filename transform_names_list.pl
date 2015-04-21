#! /usr/bin/perl -w

die "Use this to transform the output of pre.cluster in mothur to a list
Usage: mothurnames > redirect\n" unless (@ARGV);

($otulist)=(@ARGV);
chomp ($otulist);

open (IN, "<$otulist" ) or die "Can't open $otulist\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($parent, @allgroups)=split ("\t", $line);
    print "$parent";
    foreach $gOTU (@allgroups){
	(@groups)=split (",", $gOTU);
	foreach $name (@groups){
	    print "\t$name" unless ($name eq $parent);
	}
	print "\n";
    }
}
close (IN);

