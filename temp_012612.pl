#! /usr/bin/perl -w

die "Usage: true_OTUs file > redirect\n" unless (@ARGV);

($true, $mat)=(@ARGV);
chomp ($mat);
chomp ($true);

open (IN, "<$true" ) or die "Can't open $true\n";
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    $truehash{$line}++;
}
close (IN);

print "Cutoff\tCorrect\tMerged\tMissed\n";
open (IN, "<$mat" ) or die "Can't open $mat\n";
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    $corOTUhash=0;
    $mergeOTUhash=0;
    $misOTUhash=0;
    ($cutoff, $number, @p)=split ("\t", $line);
    foreach $OTU (@p){
	(@merged)=split (",", $OTU);
	$truecount=0;
	%mapping=();
	foreach $mOTU (@merged){
	    if ($truehash{$mOTU}){
		$truecount++;
	    }
	}
	if ($truecount==1){
	    #then it is a true OTU
	    $corOTUhash++;
	} elsif ($truecount>1){
	    $mergeOTUhash++;
	} else {
	    $misOTUhash++;
	}
    }
    print "$cutoff\t$corOTUhash\t$mergeOTUhash\t$misOTUhash\n";
}
close (IN);
