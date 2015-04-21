#! /usr/bin/perl -w

die "Usage: rdp ids > redirect\n" unless (@ARGV);
($rdp, $id) = (@ARGV);
chomp ($rdp, $id);

open (IN1, "<$rdp" ) or die "Can't open $rdp\n";
while ($line1 =<IN1>){
    chomp ($line1);
    next unless ($line1);
    (@pieces)=split ("\t", $line1);
    ($OTU)=shift(@pieces);
    die "$OTU\n";
}

close (IN1);



