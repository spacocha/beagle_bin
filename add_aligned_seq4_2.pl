#! /usr/bin/perl -w

die "Usage: tab fa trans\n" unless (@ARGV);
($tab, $fa, $trans) = (@ARGV);
chomp ($tab);
chomp ($fa);
chomp ($trans);

$/=">";
open (IN, "<$fa" ) or die "Can't open $fa\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($newline, @seqs)=split ("\n", $line);
    if ($newline=~/^.+_[0-9]+$/){
	($OTU)=$newline=~/^(.+)_[0-9]+$/;
    } else {
	($OTU)=$newline;
    }
    ($sequence)=join ("", @seqs);
    $seqhash{$OTU}=$sequence;
}
close (IN);

$/="\n";
open (IN, "<$trans" ) or die "Can't open $trans\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $OTU)=split ("\t", $line);
    $namehash{$name}=$OTU;
}
close (IN);

open (IN, "<$tab" ) or die "Can't open $tab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @pieces)=split ("\t", $line);
    print "$name";
    foreach $piece (@pieces){
	print "\t$piece";
    }
    if ($seqhash{$namehash{$name}}){
	print "\t$seqhash{$namehash{$name}}\t$namehash{$name}\n";
    } else {
	print "\tremoved\tremoved\n";
    }
}
close (IN);
