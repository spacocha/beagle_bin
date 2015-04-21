#! /usr/bin/perl -w

die "Usage: map2mock mat > redirect\n" unless (@ARGV);
($map, $mat) = (@ARGV);
chomp ($mat);
chomp ($map);

open (IN, "<$map" ) or die "Can't open $map\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($oldOTU, $clone)=split ('\|', $line);
    (@pieces)=split ("\t", $clone);
    ($clonename)=$pieces[1];
    ($OTUno)=$oldOTU=~/\D*([0-9]+)$/;
    $nohash{$OTUno}=$clonename;
}
close (IN);

open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if (@headers){
	print "$OTU";
	foreach $piece (@pieces){
	    print "\t$piece";
	}
	($number)=$OTU=~/Otu0*([0-9]+?)$/;
	if ($nohash{$number}){
	    print "\t$nohash{$number}\n";
	} else {
	    print "\tNA\n";
	}
    } else {
	(@headers)=@pieces;
	print "$OTU";
	foreach $header (@headers){
	    print "\t$header";
	}
	print "\n";
    }
}
close (IN);
