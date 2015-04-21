#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: mapping <input_file> <output>\n" unless (@ARGV);
	
chomp (@ARGV);
($map, $file) = (@ARGV);


open (IN, "<${map}") or die "Can't open $map\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($lib, $bar)=split ("\t", $line);
    $hash{$bar}=$lib;
}
close (IN);

$/=">";
$count=1;
open (IN, "<${file}") or die "Can't open $file\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $seq)=split ("\n", $line);
    ($bar)=$name=~/\#([A-z]+)\/[0-9]/;
    if ($hash{$bar}){
	print ">$hash{$bar}_${count} $name\n$seq\n";
	$count++;
    }
}
close (IN);

