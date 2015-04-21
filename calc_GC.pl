#! /usr/bin/perl -w
#
#

	die "Usage: tab > redirect\n" unless (@ARGV);
	($file1) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);

open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($info, $seq)=split ("\t", $line);
    $seq=~s/-//g;
    (@bps)=split ("", $seq);
    $total=0;
    $GC=0;
    foreach $bp (@bps){
	$GC++ if ($bp eq "G" || $bp eq "C");
	$total++;
    }
    $percent=(100*${GC})/${total};
    print "$info\t$GC\t$total\t$percent\n";
}

