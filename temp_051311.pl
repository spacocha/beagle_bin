#! /usr/bin/perl -w

die "Usage: .trans .tab > redirect\n" unless (@ARGV);
($trans, $tab) = (@ARGV);
chomp ($trans);
chomp ($tab);

open (IN, "<$tab" ) or die "Can't open $tab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $file)=split ("\t", $line);
    ($gi)=$name=~/gi\|([0-9]+)\:/;
    $filehash{$gi}=$file;
}
close (IN);

open (IN, "<$trans" ) or die "Can't open $trans\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $gi)=split ("\t", $line);    
    if ($filehash{$gi}){
	print "$name\t$gi\t$filehash{$gi}\n";
    } else {
	die "No file $gi\n";
    }
} 
close (IN);

