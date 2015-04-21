#! /usr/bin/perl -w

die "Usage: true_OTUs list type mat_(optional) > redirect\n" unless (@ARGV);

($true, $list, $type, $mat)=(@ARGV);
if ($mat){
    chomp ($mat);
}
chomp ($true);
chomp ($list);
chomp ($type);

open (IN, "<$true" ) or die "Can't open $true\n";
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, $ref)=split ("\t", $line);
    if ($OTU=~/^(ID.+M)/){
	($newOTU)=$OTU=~/^(ID.+M)/;
    } else {
	$newOTU=$OTU;
    }
    $truehash{$newOTU}=$ref;
}
close (IN);

$corOTUhash=0;
$mergeOTUhash=0;
$misOTUhash=0;
$corSUMhash=0;
$mergeSUMhash=0;
$misSUMhash=0;
if ($mat){
    $first=1;
    open (IN, "<$mat" ) or die "Can't open $mat\n";
    while ($line =<IN>){
	chomp ($line);
	next unless ($line);
	($OTU, @p)=split ("\t", $line);
	if ($OTU=~/^ID.+M/){
	    ($newOTU)=$OTU=~/^(ID.+M)/;
	} else {
	    ($newOTU)=$OTU;
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
}
print "$list\n";
open (IN, "<$list" ) or die "Can't open $list\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    if ($type eq "eco"){
	(@p)=split ("\t", $line);
    } elsif ($type eq "phylo"){
	($num, @p)=split ("\t", $line);
    } else {
	die "Don't recognize type $type\nMust be eco or phylo\n";
    }
    $truecount=0;
    $wheresum=0;
    foreach $OTU (@p){
	if ($OTU=~/ID.+M/){
	    ($newOTU)=$OTU=~/^(ID.+M)/;
	} else {
	    ($newOTU)=$OTU;
	}
	if ($truehash{$newOTU}){
	    $truecount++;
	}
	if ($mat){
	    if ($gothash{$newOTU}){
		$wheresum+=$mathash{$newOTU};
	    } else {
		die "Missing $newOTU from mat\n";
	    }
	} else {
	    $wheresum++;
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

print "list\tCorrect\tMerged\tMissed
$list\t$corOTUhash\t$mergeOTUhash\t$misOTUhash\tOTUnum
$list\t$corSUMhash\t$mergeSUMhash\t$misSUMhash\tSum\n";
