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
    if ($OTU=~/\/ab=[0-9]+\/*$/){
	($newOTU)=$OTU=~/^(.+)\/ab=[0-9]+\/*$/;
    } elsif ($OTU=~/^(ID.+M)/){
	($newOTU)=$OTU=~/^(ID.+M)/;
    } elsif ($OTU=~/(.+_[0-9]+?) /){
	($newOTU)=$OTU=~/(.+_[0-9]+?) /;
    } else {
	$newOTU=$OTU;
    }
    unless ($done{$OTU}){
	$truehash{$newOTU}=$ref;
	$totalrefmap{$ref}++;
	$done{$OTU}++;
    }
}
close (IN);
foreach $ref (sort keys %totalrefmap){
    print "It's in the totalrefmap $ref\n";
    $total++;
}
print "Total mapping ref seqs: $total\n";

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
	if ($OTU=~/\/ab=[0-9]+\/*$/){
	    ($newOTU)=$OTU=~/^(.+)\/ab=[0-9]+\/*$/;
	} elsif ($OTU=~/^ID.+M/){
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
    %truecount=();
    $wheresum=0;
    foreach $OTU (@p){
	if ($OTU=~/ID.+M/){
	    ($newOTU)=$OTU=~/^(ID.+M)/;
	} elsif ($OTU=~/QiimeExactMatch\./){
	    ($newOTU)=$OTU=~/QiimeExactMatch\.(.+)$/;
	} else {
	    ($newOTU)=$OTU;
	}
	if ($truehash{$newOTU}){
	    $ref=$truehash{$newOTU};
	    $truecount{$ref}++;
	    $gottcha{$ref}++;
	    print "It's recorded as a true in both truecount and gottcha $ref for $newOTU\n";
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
    $howmany=0;
    print "This OTU contains:\n";
    foreach $ref (keys %truecount){
	print "In an OTU: $ref\t$truecount{$ref}\n";
	$howmany++;
    }
    if ($howmany==1){
	#then it is a true OTU
	$corOTUhash++;
	$corSUMhash+=$wheresum;
	print "Its a true OTU\n";
    } elsif ($howmany>1){
	print "Merged:";
	foreach $ref (keys %truecount){
		print "\t$ref";
	}
	print "\n";
	$mergeOTUhash++;
	$mergeSUMhash+=$wheresum;
	print "It's a merged OTU\n";
    } else {
	$misOTUhash++;
	$misSUMhash+=$wheresum;
	print "It's a missing OTU\n";
    }
}

foreach $ref (sort keys %totalrefmap){
    print "Ref $ref : totalrefmap $totalrefmap{$ref} gottcha $gottcha{$ref}\n";
}

close (IN);

print "list\tCorrect\tMerged\tMissed
$list\t$corOTUhash\t$mergeOTUhash\t$misOTUhash\tOTUnum
$list\t$corSUMhash\t$mergeSUMhash\t$misSUMhash\tSum\n";
