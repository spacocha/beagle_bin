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

$corOTUhash=0;
$mergeOTUhash=0;
$misOTUhash=0;

open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@p)=split ("\t", $line);
    $truecount=0;
    foreach $OTU (@p){
	$truecount++ if ($truehash{$OTU});
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


close (IN);

print "MAT\tCorrect\tMerged\tMissed
$mat\t$corOTUhash\t$mergeOTUhash\t$misOTUhash\n";
