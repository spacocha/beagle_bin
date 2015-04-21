#! /usr/bin/perl -w

die "Usage: groups map2mock\n" unless (@ARGV);
($mat, $map) = (@ARGV);
chomp ($mat);
chomp($map);

open (IN, "<$map" ) or die "Can't open $map\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($ID, $ref)=split ("\t", $line);
    $hash1{$ID}=$ref;
}
close (IN);

open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($group, $ID)=split (",", $line);
    if ($hash1{$ID}){
	if ($groupwID{$group}){
	    die "Already has an ID $group\n";
	} else {
	    $groupwID{$group}=$hash1{$ID};
	}
    } else {
	$grouptotal{$group}++;
    }
}
close (IN);

foreach $group (sort {$a <=> $b} keys %grouptotal){
    if ($groupwID{$group}){
	print "HAS group: $group\tTotal: $grouptotal{$group}\tID: $groupwID{$group} $grouptotal{$group}\n";
    } else {
	print "HAS NOT: $group\t$grouptotal{$group}\tNA\n";
    }
}
