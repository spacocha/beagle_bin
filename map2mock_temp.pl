#! /usr/bin/perl -w

die "Usage: map2mock mat > redirect\n" unless (@ARGV);
($map, $mat) = (@ARGV);
chomp ($mat);
chomp ($map);

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
    $hash{$clone}=$OTU;
}
close (IN);

open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, $OTU2, @pieces)=split ("\t", $line);
    print "$OTU\t$hash{$OTU}\t$OTU2\t$hash{$OTU2}";
    foreach $piece (@pieces){
	print "\t$piece";
    }
    print "\n";
}
close (IN);
