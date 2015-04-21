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
	print "$name\t$name\n";
    } elsif ($type ne "C"){
	print "$name\t$seedname\n";
    }
}
close (IN);

#make a table of total counts per seed cluster

