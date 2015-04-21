#! /usr/bin/perl -w

die "Usage: map2mock res > redirect\n" unless (@ARGV);

($map, $res)=(@ARGV);
chomp ($map, $res);

open (IN, "<$map" ) or die "Can't open $map\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU1, $ref)=split ("\t", $line);
    $truehash{$OTU1}=$ref;
}
close (IN);

open (IN, "<$res" ) or die "Can't open $res\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($num, $comiso)=split ("\t", $line);
    ($trueiso)=$comiso=~/^(.+)\/ab=/;
    if ($truehash{$trueiso}){
	if ($line=~/Y$/){
	    print "true\t$trueiso\tCHIMERA\n";
	}
    }
}
close (IN);
