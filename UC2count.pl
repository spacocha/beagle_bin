#! /usr/bin/perl -w
#
#

	die "Usage: UC_file > Redirect\n" unless (@ARGV);
	($file1) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);



open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/^#/);
    ($type, $seed, $len, $one, $two, $three, $four, $five, $name, $seedname)=split (" ", $line);
    if ($type eq "S"){
	$seedname = $name;
	$seedno{$seedname}=$seed;
	#foreach name or seed there are two things
	#both the total number of names in that seed
	#and the total number of seqs for that name
	#the following counts all the seqs for that name
	#iterating over all instances count the total number of names in that seed
	$uchash{$seedname}++;
    } elsif ($type ne "C"){
	$uchash{$seedname}++;
    }
}
close (IN);

#make a table of total counts per seed cluster

    foreach $seed (sort {$uchash{$b} <=> $uchash{$a}} keys %uchash){
	#I want to replace the long tree name with a new name that has counts in it
	#the format is $seedno{$seed}|*|$seed
	#replace with $seed|*|$uchash{$seed}
	print "$seed\t$uchash{$seed}\n";

    }

