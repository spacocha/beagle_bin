#! /usr/bin/perl
#
#

	die "Usage: Vtrans Vblast Jtrans Jblast > redirect\n" unless (@ARGV);
	($vtrans, $vblast, $jtrans, $jblast) = (@ARGV);

	die "Please follow command line args\n" unless ($jblast);
chomp ($vtrans);
chomp ($vblast);
chomp ($jtrans);
chomp ($jblast);

open (IN1, "<$vtrans") or die "Can't open $vtrans\n";
while ($line=<IN1>){
    chomp ($line);
    next unless ($line);
    ($shrt, $long)=split ("\t", $line);
    $vhash{$shrt}=$long;
}
close (IN1);

open (IN1, "<$jtrans") or die "Can't open $jtrans\n";
while ($line=<IN1>){
    chomp ($line);
    next unless ($line);
    ($shrt, $long)=split ("\t", $line);
    $jhash{$shrt}=$long;
}
close (IN1);

open (IN1, "<$vblast") or die "Can't open $vblast\n";
while ($line=<IN1>){
    chomp ($line);
    next unless ($line);
    ($shrt, $long)=split ("\t", $line);
    if ($vhash{$shrt}){
	$Vblasthash{$vhash{$shrt}}=$long;
    } else {
	die "Missing a long name $shrt $vblast\n";
    }
}
close (IN1);

open (IN1, "<$jblast") or die "Can't open $jblast\n";
while ($line=<IN1>){
    chomp ($line);
    next unless ($line);
    ($shrt, $long)=split ("\t", $line);
    if ($jhash{$shrt}){
	$Jblasthash{$jhash{$shrt}}=$long;
    } else {
	die "Missing a long name $shrt $jblast\n";
    }
}
close (IN1);

foreach $name (sort keys %Jblasthash){
    if ($Vblasthash{$name}){
	#print "$name\t$Vblasthash{$name}\t$Jblasthash{$name}\n";
	$combohash{$Vblasthash{$name}}{$Jblasthash{$name}}++;
    }
}

foreach $Vregion (sort {$combohash{$b} <=> $combohash{$a}} keys %combohash){
    foreach $Jregion (sort {$combohash{$Vregion}{$b} <=> $combohash{$Vregion}{$a}} keys %{$combohash{$Vregion}}){
	print "$Vregion\t$Jregion\t$combohash{$Vregion}{$Jregion}\n";
    }
}
