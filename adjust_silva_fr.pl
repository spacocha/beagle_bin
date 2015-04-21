#! /usr/bin/perl -w

die "Usage: <silvaf> <front> <silvar> <drop> <reverse> > redirect" unless (@ARGV);
($filef, $keepfront, $filer, $drop, $keeprev) = (@ARGV);
chomp ($filef);
chomp ($keepfront);
chomp ($filer);
chomp ($drop);
chomp ($keeprev);

$/=">";
open (IN, "<$filef" ) or die "Can't open $filef\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @pieces)=split ("\n", $line);
    ($sequence) = join ("", @pieces);
    $fhash{$name}=$sequence;
}
close (IN);

open (IN, "<$filer" ) or die "Can't open $filer\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @pieces)=split ("\n", $line);
    ($sequence) = join ("", @pieces);
    if ($fhash{$name}){
	#
	($frontseq)=$fhash{$name}=~/^.(.{$keepfront})/;
	($revseq)=$sequence=~/^.{$drop}(.{$keeprev})/;
	print ">$name\n${frontseq}${revseq}\n";
    } else {
	die "Doesn't have a front half: $name\n";
    }
}
close (IN);

