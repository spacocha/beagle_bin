#! /usr/bin/perl -w

die "Usage: blast map2mock mat\n" unless (@ARGV);
($blast, $map, $mat) = (@ARGV);
chomp ($blast);
chomp($map);
chomp ($mat);

open (IN, "<$blast" ) or die "Can't open $blast\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, $mock)=split ("\t", $line);
    if ($OTU=~/_[0-9]+$/){
	($newOTU)=$OTU=~/^(.+)_[0-9]+$/;
    } else {
	$newOTU=$OTU;
    }
    $blasthash{$newOTU}=$mock;
}
close (IN);

open (IN, "<$map" ) or die "Can't open $map\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, $mock)=split ("\t", $line);
    if ($OTU=~/_[0-9]+$/){
	($newOTU)=$OTU=~/^(.+)_[0-9]+$/;
    } else {
	$newOTU=$OTU;
    }
    $maphash{$newOTU}=$mock;
}
close (IN);

open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @mats)=split ("\t", $line);
    if ($OTU=~/_[0-9]+$/){
	($newOTU)=$OTU=~/^(.+)_[0-9]+$/;
    } else {
	$newOTU=$OTU;
    }
    $blasthash{$newOTU}="NA" unless ($blasthash{$newOTU});
    $maphash{$newOTU}="NA" unless ($maphash{$newOTU});
    print "$newOTU\t$maphash{$newOTU}\t$blasthash{$newOTU}";
    foreach $val (@mats){
	print "\t$val";
    }
    print "\n";

}
close (IN);
