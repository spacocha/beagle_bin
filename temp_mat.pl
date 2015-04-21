#! /usr/bin/perl -w

die "Use this for filtering mats
Usage: otu_table > redirect\n" unless (@ARGV);
($table) = (@ARGV);
chomp ($table);

$first=1;
open (IN, "<$table" ) or die "Can't open $table\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    if ($first){
	print "$line\n";
	$first=();
    } else {
	($OTU, @info)=split ("\t", $line);
	$total=0;
	foreach $in (@info){
	    $total+=$in;
	}
	if ($total>1){
	    print "$line\n";
	}
    }
}
close (IN);
