#! /usr/bin/perl -w
#
#

	die "Usage: Table UC_file tree > Redirect\n" unless (@ARGV);
	($file1, $file2, $file3) = (@ARGV);

	die "Please follow command line args\n" unless ($file3);
chomp ($file1);
chomp ($file2);
chomp ($file3);


	open (IN, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($sol_name, $fastaname)=split ("\t", $line);
		($shrt_name) = $sol_name=~/^(.+\#[A-Z]{7})\//;
		$shash{$shrt_name}=$fastaname;
		$fastahash{$fastaname}++; #this is the total number of seqs for this fastaname
       	}
	close (IN);

open (IN, "<$file2") or die "Can't open $file2\n";
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
	$uchash{$seedname}+=$fastahash{$name};
    } elsif ($type ne "C"){
	$uchash{$seedname}+=$fastahash{$name};
    }
}
close (IN);

#make a table of total counts per seed cluster

open (IN, "<$file3") or die "Can't open $file3\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    if ($newline){
	$newline = "$newline"."$line";
    } else {
	$newline = $line;
    }
}
close (IN);

    foreach $seed (keys %uchash){
	#I want to replace the long tree name with a new name that has counts in it
	#the format is $seedno{$seed}|*|$seed
	#replace with $seed|*|$uchash{$seed}
	$newline=~ s/${seedno{$seed}}\|\*\|${seed}/${seed}\|\*\|${uchash{$seed}}/g;

    }

    print "$newline\n";
