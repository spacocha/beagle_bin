#! /usr/bin/perl -w

die "Usage: mat cut-off > redirect\n" unless (@ARGV);
($mat, $thresh) = (@ARGV);
chomp ($mat);
chomp ($thresh);

open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if (@headers){
	$sum=0;
	foreach $piece (@pieces){
	    $sum+=$piece;
	}
	unless ($sum<=$thresh){
	    print "$OTU";
	    foreach $piece(@pieces){
		print "\t$piece";
	    }
	    print "\n";
	}
    } else {
	(@headers)=@pieces;
	print "OTU";
	foreach $head (@pieces){
	    print "\t$head";
	}
	print "\n";
    }
}
close (IN);

