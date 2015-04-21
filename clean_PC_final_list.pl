#! /usr/bin/perl -w

die "Usage: unique.PC.final.list> redirect\n" unless (@ARGV);
($merge) = (@ARGV);
chomp ($merge);

$lineno=0;
open (IN, "<$merge" ) or die "Can't open $merge\n";
while ($line =<IN>){
    $lineno++;
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    if ($pieces[1]){
	print "$line\n";
    } #should put in here the files that can be made that have just one seq
}

close (IN);

