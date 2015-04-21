#! /usr/bin/perl -w

die "Usage: <tab> > redirect" unless (@ARGV);
($tab) = (@ARGV);
chomp ($tab);

open (IN, "<$tab" ) or die "Can't open $tab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $lib, $fseq, $fqual, $rseq, $rqual, $falign, $FC, $UC, $OTU, $ralign) = split ("\t", $line);
    next unless ($falign=~/^[ATGC-]+$/ && $ralign=~/^[ATGC-]+$/);
    (@fbases) = split ("", $falign);
    $flen = @fbases;
    (@rbases) =split ("", $ralign);
    $rlen = @rbases;
    $fdisthash{$flen}++;
    $rdisthash{$rlen}++;
}

close (IN);

foreach $length (sort {$a <=> $b} keys %fdisthash){ 
    print "F: $length $fdisthash{$length}\n";
}

foreach $length(sort {$a <=> $b} keys %rdisthash){
    print "R: $length $rdisthash{$length}\n";
}

