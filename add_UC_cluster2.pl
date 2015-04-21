#! /usr/bin/perl -w
#
#

	die "Use this program to take the UCLUST groups and make a consensus (> 75% identity) sequence to run through chimera checker
Usage: UC_file tab_file namecol\n" unless (@ARGV);
	($uc, $tab, $namecol) = (@ARGV);

	die "Please follow command line args\n" unless ($tab);
chomp ($uc);
chomp ($tab);
chomp ($namecol);
$namecolm1=$namecol-1;
$count=1;
open (IN, "<$uc") or die "Can't open $uc\n";
open (OUT, ">${uc}.trans") or die "Can't open ${uc}.trans\n";

while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/^\#/);
    ($type, $seed, $len, $one, $two, $three, $four, $five, $name, $seedname)=split (" ", $line);
    if ($type eq "S"){
	$seedname = $name;
	(@pieces) = split ("", $count);
	$these = @pieces;
	$zerono = 7 - $these;
	$zerolet = "0";
	$zeros = $zerolet x $zerono;
	$seedname2= "UC"."${zeros}${count}"."P";
	$count++;
	$seednamehash{$seedname}=$seedname2;
	#foreach name or seed there are two things
	#both the total number of names in that seed
	#and the total number of seqs for that name
	#the following counts all the seqs for that name
	#iterating over all instances count the total number of names in that seed
	$uchash{$name}=$seedname2;
	print OUT "$seedname\t$seedname2\n";
    } elsif ($type ne "C"){
	$uchash{$name}=$seednamehash{$seedname};
    }
}
close (IN);

open (IN, "<$tab") or die "Can't open $tab\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces) = split ("\t", $line);
    foreach $piece (@pieces){
	print "$piece\t";
    }
    $name=$pieces[$namecolm1];
    if ($uchash{$name}){
	#found the uc cluster for this sequence
	print "$uchash{$name}\n";
    } else {
	print "removed\n";
    }

}
close (IN);
