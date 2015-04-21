#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: map > redirect\n" unless (@ARGV);
	
chomp (@ARGV);
($map) = (@ARGV);


open (IN, "<${map}") or die "Can't open $map\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $ref)=split ("\t", $line);
    if ($name=~/^ID.+M/){
	($newname)=$name=~/^(ID.+M)/;
    } else {
	$newname=$name;
    }
    $hash{$newname}=$ref;
}
close (IN);

foreach $name (sort keys %hash){
    print "$name\t$hash{$name}\n";
}
