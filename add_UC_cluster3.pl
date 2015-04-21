#! /usr/bin/perl -w
#
#

	die "Use this program to take the UCLUST groups
Usage: UC_file tab_file namecol seed_y/n\n" unless (@ARGV);
	($uc, $tab, $namecol, $seedyn) = (@ARGV);

	die "Please follow command line args\n" unless ($tab);
chomp ($uc);
chomp ($tab);
chomp ($namecol);
chomp ($seedyn);
$namecolm1=$namecol-1;
$count=1;
open (IN, "<$uc") or die "Can't open $uc\n";

while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/^\#/);
    ($type, $seed, $len, $one, $two, $three, $four, $five, $name, $seedname)=split (" ", $line);
    if ($type eq "S"){
	if ($seedyn=~/y/){
	    ($seedname2)=$seedname=~/[0-9]*\|*\**\|*(.+)$/;
	} else {
	    $seedname2 = $name;
	}
	$seednamehash{$seedname2}=$seedname2;
	#foreach name or seed there are two things
	#both the total number of names in that seed
	#and the total number of seqs for that name
	#the following counts all the seqs for that name
	#iterating over all instances count the total number of names in that seed
	$uchash{$name}=$seedname2;
    } elsif ($type ne "C"){
	$uchash{$name}=$seednamehash{$seedname};
    }
#    die "Here $name\n" if ($name eq "UC0004453P");
}
close (IN);

#foreach $name (keys %uchash){
#    print "IN $name\n";
#}

open (IN, "<$tab") or die "Can't open $tab\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces) = split ("\t", $line);
    foreach $piece (@pieces){
	print "$piece\t";
    }
    ($name)=$pieces[$namecolm1];
    if ($uchash{$name}){
	#found the uc cluster for this sequence
	print "$uchash{$name}\n";
    } else {
	print "\tremoved\n";
    }

}
close (IN);
