#! /usr/bin/perl -w

die "Usage: tab_file > redirect\n" unless (@ARGV);
($new) = (@ARGV);
chomp ($new);

$first=1;
open (IN, "<$new" ) or die "Can't open $new\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @pieces) = split ("\t", $line);
    if ($first){
	$first=0;
	print "$info";
	foreach $piece (@pieces){
	    print "\t$piece";
	}
    } else {
	print "$info";
	foreach $piece (@pieces){
	    if ($piece){
		print "\t1";
	    } else {
		print "\t$piece";
	    }
	}
    }
    print "\n";
} 
close (IN);

