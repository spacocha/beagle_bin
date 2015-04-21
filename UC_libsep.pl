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
	($lib, $count)=$name=~/^(.+)_[0-9]+_([0-9]+)$/;
	$ibhash{$lib}++;
	#foreach name or seed there are two things
	#both the total number of names in that seed
	#and the total number of seqs for that name
	#the following counts all the seqs for that name
	#iterating over all instances count the total number of names in that seed
	$uchash{$seedname}{$lib}+=$count;
    } elsif ($type ne "C"){
	$libhash{$lib}++;
	($lib, $count)=$name=~/^(.+)_[0-9]+_([0-9]+)$/;
	$uchash{$seedname}{$lib}+=$count;
	
    }
}
close (IN);

#make a table of total counts per seed cluster
    print "Seed";
        foreach $lib (sort keys %libhash){
            print "\t$lib";
        }
    print "\n";

    foreach $seed (sort {$uchash{$b} <=> $uchash{$a}} keys %uchash){
	#I want to replace the long tree name with a new name that has counts in it
	#the format is $seedno{$seed}|*|$seed
	#replace with $seed|*|$uchash{$seed}
	print "$seed";
	foreach $lib (sort keys %libhash){
	    if ($uchash{$seed}{$lib}){
		print "\t$uchash{$seed}{$lib}";
	    } else {
		print "\t0";
	    }

	}
	print "\n";
    }

