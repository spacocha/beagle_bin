#! /usr/bin/perl -w

die "Use this to make count table from a list
Names must be in QIIME format (lib_no)
Usage: list > redirect\n" unless (@ARGV);
($file) = (@ARGV);
chomp ($file);

open (IN, "<$file" ) or die "Can't open $file\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs)=split ("\t", $line);
    foreach $seq (@seqs){
	if ($seq=~/^(.+)_[0-9]+$/){
	    ($lib)=$seq=~/^(.+)_[0-9]+$/;
	    $libhash{$lib}++;
	    $counthash{$info}{$lib}++;
	} else {
	    die "Can't find lib in name $seq\n";
	}
    }
}
close (IN);

print "OTU";
foreach $lib (sort keys %libhash){
    print "\t$lib";
}
print "\n";

foreach $otu (sort keys %counthash){
    print "$otu";
    foreach $lib (sort keys %libhash){
	if ($counthash{$otu}{$lib}){
	    print "\t$counthash{$otu}{$lib}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}
