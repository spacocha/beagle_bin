#! /usr/bin/perl -w

die "Usage: true_OTUs mat list type > redirect\n" unless (@ARGV);

($true, $mat, $list, $type)=(@ARGV);
chomp ($mat);
chomp ($true);

open (IN, "<$true" ) or die "Can't open $true\n";
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($id, $match)=split ("\t", $line);
    $truehash{$id}++;
}
close (IN);

$corOTUhash=0;
$mergeOTUhash=0;
$misOTUhash=0;
$corSUMhash=0;
$mergeSUMhash=0;
$misSUMhash=0;
$first=1;
open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @p)=split ("\t", $line);
    ($lin)=pop(@p);
    if (@headers){
	foreach $val (@p){
	    if ($truehash{$OTU}){
		$truecount+=$val;
	    } else{
		$falsecount+=$val;
	    }
	}
    } else {
	(@headers)=@p;
    }
}
close (IN);

print "MAT\tCorrect\tMissed
$mat\t$truecount\t$falsecount\n";
