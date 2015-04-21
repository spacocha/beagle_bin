#! /usr/bin/perl -w

die "Usage: results map2mock > redirect\n" unless (@ARGV);
($res, $map) = (@ARGV);
chomp ($map);
chomp ($res);

open (IN, "<$map" ) or die "Can't open $map\n";
while ($line =<IN>){
    chomp ($line);
    ($OTU, $ID)=split ("\t", $line);
    if ($maphash{$OTU}){
	print "Hits twice OTU: $OTU ID: $ID old ID: $maphash{$OTU}\n";
    }
    if ($IDhash{$ID}){
	print "Hit twice ID: $ID: OTU1: $OTU old OTU: $IDhash{$ID}\n";
    }
    $maphash{$OTU}=$ID;
    $IDhash{$ID}=$OTU;
}
close (IN);

open (IN, "<$res" ) or die "Can't open $res\n";
while ($line =<IN>){
    chomp ($line);
    if ($line=~/Change/){
	($changefrom, $child, $parent)=split (",", $line);
	$parenthash{$parent}++;
	$childhash{$child}++;
	if ($maphash{$child}){
	    print "Child mapping: $child Parent: $parent\n";
	}
    } elsif ($line=~/: Done testing as child/){
	($OTU)=$line=~/^(.+): Done testing as child/;
	$total{$OTU}++;
    }
}
close (IN);

foreach $child (keys %childhash){
    if ($maphash{$child}){
	$childmap++;
    }
}
foreach $parent (keys %parenthash){
    if ($maphash{$parent}){
	$parentmap++;
    }
}
foreach $OTU (keys %total){
    if ($maphash{$OTU}){
	$totalmap++;
    }
}

print "Child map: $childmap
Parent map:$parentmap
Total map: $totalmap\n";
