#! /usr/bin/perl -w

die "Usage: list > redirect\n" unless (@ARGV);

($list)=(@ARGV);
chomp ($list);

open (IN, "<$list" ) or die "Can't open $list\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@p)=split ("\t", $line);
    $first=1;
    foreach $OTU (@p){
	if ($OTU=~/ID.+M/){
	    ($newOTU)=$OTU=~/^(ID.+M)/;
	} else {
	    ($newOTU)=$OTU;
	}
	if ($first){
	    print "$newOTU" unless ($printed);
	    $first=0;
	} else {
	    print "\t$newOTU" unless ($printed{$newOTU});
	    $printed{$newOTU}++;
	}
    }
    print "\n";
}


close (IN);

