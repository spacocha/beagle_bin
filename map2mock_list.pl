#! /usr/bin/perl -w

die "Usage: map2mock list list_type> redirect\n" unless (@ARGV);
($map, $list, $type) = (@ARGV);
chomp ($list);
chomp ($map);
chomp ($type);

open (IN, "<$map" ) or die "Can't open $map\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($oldOTU, $clone)=split ("\t", $line);
    if ($oldOTU=~/^ID.+M/){
	($OTU)=$oldOTU=~/^(ID.+M)/;
    } else {
	($OTU)=$oldOTU;
    }
    $hash{$OTU}=$clone;
}
close (IN);

open (IN, "<$list" ) or die "Can't open $list\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    if ($type eq "eco"){
	(@pieces)=split ("\t", $line);
    } elsif ($type eq "phylo") {
	($OTU, @pieces)=split ("\t", $line);
    }
    $matches = ();
    ($OTU)=$pieces[0] if ($type eq "eco");
    foreach $otu (@pieces){
	if ($hash{$otu}){
	    if ($matches){
		print "\t$hash{$otu}";
	    } else {
		print "$OTU\t$hash{$otu}";
	    }
	    $matches++;
	}
    }
    print "\n" if ($matches);
}
close (IN);
