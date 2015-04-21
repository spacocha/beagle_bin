#! /usr/bin/perl -w

die "Use this to transform the output of mothur cluster() to list
Usage: mothurlist cutoff > redirect\n" unless (@ARGV);

($otulist, $cutoffval)=(@ARGV);
chomp ($otulist);
chomp ($cutoffval);

open (IN, "<$otulist" ) or die "Can't open $otulist\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    #next if ($line=~/unique/);
    ($cutoff, $number, @allgroups)=split ("\t", $line);
    next unless ($cutoff eq $cutoffval);
    foreach $gOTU (@allgroups){
	$count++;
	print "Otu";
	##make cluster name                                                                                                                                                                            
	(@get)=split("", $count);
	$fill=@get;
	$zeros=3-$fill;
	$i=0;
	until ($i >= $zeros){
	    print "0";
	    $i++;
	}
	print "$count\t";
	
	(@groups)=split (",", $gOTU);
	foreach $name (@groups){
	    print "$name\t";
	}
	print "\n";
    }
}
close (IN);

