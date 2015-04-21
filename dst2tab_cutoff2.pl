#! /usr/bin/perl -w
#
#

	die "Use this file with a .dst file from clustal to get a 
pairwise tab del output for 1 isolate 2 isolate dist
Usage: inputfile cutoff_val Redirect\n" unless (@ARGV);
	($file, $cutoff, $output) = (@ARGV);
	chomp ($file);
	$k=0;

$first=1;
open (IN, "<$file") or die "Can't open $file\n";
open (OUT, ">${output}.tab") or die "Can't open ${output}.tab\n";
while ($line=<IN>){
    chomp ($line);
    (@pieces) = split (" ", $line);
    if ($first){
	$first=();
    } else {
	if ($pieces[0] =~/[A-z]/){
#start a new entry
	    ($isolate) = shift (@pieces);
	    $j=1;
	    $k++;
	    $translatehash2{$k}=$isolate;
	}
	
	$i=0;
	$ij=@pieces;
	until ($i >=$ij){
	    print OUT "$k\t$j\t$pieces[$i]\n" if ($pieces[$i] <= $cutoff);
	$j++;
	    $i++;
	}
	
    }
}
print "Finished\n";
close (IN);
close (OUT);

open (OUT, ">${output}.trans") or die "Can't open ${output}.trans\n";
foreach $num (sort keys %translatehash2){
    print OUT "$num\t$translatehash2{$num}\n";
}
close (OUT);

