#! /usr/bin/perl -w

die "Usage: unique.fa > redirect\n" unless (@ARGV);

($fa)=(@ARGV);
chomp ($fa);

$/=">";
$first=1;
open (IN, "<$fa" ) or die "Can't open $fa\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($new)=split ("\n", $line);
    ($newnew)=$new=~/^(ID.{7}M)/;
    if ($first){
	$first=0;
	print "$newnew";
    } else {
	print "\t$newnew";
    }
}
print "\n";
close (IN);
