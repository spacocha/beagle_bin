#! /usr/bin/perl -w

die "Usage: map mat list type > redirect\n" unless (@ARGV);

($map, $mat, $list, $type)=(@ARGV);
chomp ($mat);
chomp ($true);

open (IN, "<$map" ) or die "Can't open $map\n";
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU)=split ("\t", $line);
    if ($OTU=~/^ID.+M/){
	($newOTU)=$OTU=~/^(ID.+M)/;
    } else {
	$newOTU=$OTU;
    }
    $truehash{$newOTU}++;
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
    if ($OTU=~/^ID.+M/){
	($newOTU)=$OTU=~/^(ID.+M)/;
    } else {
	$newOTU=$OTU;
    }
    if (@headers){
	$gothash{$newOTU}++;
	foreach $val (@p){
	    $mathash{$newOTU}+=$val;
	}
    } else {
	(@headers)=@p;
    }
}
close (IN);
open (IN, "<$list" ) or die "Can't open $list\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    if ($type eq "eco"){
	(@p)=split ("\t", $line);
	($num)=$p[0];
    } elsif ($type eq "phylo"){
	($num, @p)=split ("\t", $line);
    } else {
	die "Don't recognize type $type\nMust be eco or phylo\n";
    }
    $truecount=0;
    $wheresum=0;
    foreach $OTU (@p){
	($newOTU)=$OTU=~/^(ID.+M)/;
	die "Changed format from ID.+M for $OTU\n" unless ($newOTU);
	if ($truehash{$newOTU}){
	    $truecount++;
	}
	if ($gothash{$newOTU}){
	    $wheresum+=$mathash{$newOTU};
	} else {
	    die "Missing $newOTU from mat\n";
	}
    }
    if ($truecount==1){
	#then it is a true OTU
	$corOTUhash++;
	$corSUMhash+=$wheresum;
    } elsif ($truecount>1){
	print "Merged:";
	foreach $OTU (@p){
	    ($newOTU)=$OTU=~/^(ID.+M)/;
	    if ($truehash{$newOTU}){
		print "\t$newOTU";
	    }
	}
	print "\n";
	$mergeOTUhash++;
	$mergeSUMhash+=$wheresum;
    } else {
	$misOTUhash++;
	$misSUMhash+=$wheresum;
    }
}


close (IN);

print "MAT\tCorrect\tMerged\tMissed
$mat\t$corOTUhash\t$mergeOTUhash\t$misOTUhash\tOTUnum
$mat\t$corSUMhash\t$mergeSUMhash\t$misSUMhash\tSum\n";
