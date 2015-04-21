#! /usr/bin/perl -w

die "Usage: <trans> <tab> > redirect" unless (@ARGV);
($trans, $tab) = (@ARGV);
chomp ($trans);
chomp ($tab);

open (IN, "<$trans" ) or die "Can't open $trans\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @pieces)=split ("\t", $line);
    foreach $piece (@pieces){
	$hash{$piece}=$name;
    }
}
close (IN);

open (IN, "<$tab" ) or die "Can't open $tab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $lib, $fseq, $fqual, $rseq, $rqual) = split ("\t", $line);
    ($bar)=$name=~/^.+\#([ATGC]{7})$/;
    die "What $name?\n" unless ($bar);
    if ($hash{$bar}){
	print "$name\t$hash{$bar}\t$fseq\t$fqual\t$rseq\t$rqual\n";
    } else {
	print "$name\t$lib\t$fseq\t$fqual\t$rseq\t$rqual\n";
    }
}
