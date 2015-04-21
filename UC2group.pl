#! /usr/bin/perl -w
#
#

	die "Use this program to take the UCLUST groups and make a consensus (> 75% identity) sequence to run through chimera checker
Usage: UC_file FreClu2group_output\n" unless (@ARGV);
	($file1, $file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file1);
chomp ($file2);

open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/^\#/);
    ($type, $seed, $len, $one, $two, $three, $four, $five, $name, $seedname)=split (" ", $line);
    if ($type eq "S"){
	$seedname = $name;
	$seedno{$seedname}=$seed;
	#foreach name or seed there are two things
	#both the total number of names in that seed
	#and the total number of seqs for that name
	#the following counts all the seqs for that name
	#iterating over all instances count the total number of names in that seed
	$uchash{$name}=$seedname;
    } elsif ($type ne "C"){
	$uchash{$name}=$seedname;
    }
}
close (IN);

open (IN, "<$file2") or die "Can't open $file2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $freclu, $parent, $seq) = split ("\t", $line);
    if ($uchash{$freclu}){
	print "$uchash{$freclu}\t$name\t$freclu\t$parent\t$seq\n";
    } else {
	die "No uchash{freclu} $name $freclu\n";
    }
}
close (IN);

