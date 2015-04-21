#! /usr/bin/perl -w

die "Usage: list> redirect\n" unless (@ARGV);
($merge) = (@ARGV);
chomp ($merge);

open (IN, "<$merge" ) or die "Can't open $merge\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @pieces)=split ("\t", $line);
    if ($name=~/^[0-9]+$/){
	print "$name";
	foreach $piece (@pieces){
	    print "\t$piece";
	}
	print "\n";
    } elsif ($name=~/^ID[0-9]{7}M$/){
	$count++;
	print "None${count}\t$name";
	foreach $piece (@pieces){
	    print "\t$piece";
	}
	print "\n";
    }
}

close (IN);

