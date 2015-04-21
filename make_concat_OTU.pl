#! /usr/bin/perl -w

die "Usage: fasta1 trans1 fasta2 trans2 output\n" unless (@ARGV);
($fasta1, $trans1, $fasta2, $trans2, $output) = (@ARGV);
chomp ($fasta1);
chomp ($trans1);
chomp ($fasta2);
chomp ($trans2);
chomp ($output);

$/=">";
open (IN, "<$fasta1" ) or die "Can't open $fasta1\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($newline, @seqs)=split ("\n", $line);
    ($OTU, $abund)=$newline=~/^(.+)_([0-9]+)$/;
    ($seq)=join ("", @seqs);
    $fasta1hash{$OTU}=$seq;
}
close (IN);

open (IN, "<$fasta2" ) or die "Can't open $fasta2\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($newline, @seqs)=split ("\n", $line);
    ($OTU, $abund)=$newline=~/^(.+)_([0-9]+)$/;
    ($seq)=join("", @seqs);
    $fasta2hash{$OTU}=$seq;
}
close (IN);

$/="\n";
open (IN, "<$trans1" ) or die "Can't open $trans1\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($read, $OTU)=split ("\t", $line);
    $trans1hash{$read}=$OTU;
}
close (IN);
open (IN, "<$trans2" ) or die "Can't open $trans2\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($read, $OTU)=split ("\t", $line);
    $trans2hash{$read}=$OTU;
}
close (IN);

open (TRANS, ">${output}.trans") or die "Can't open ${output}.trans\n";
open (FA, ">${output}.fa") or die "Can't open ${output}.fa\n";
foreach $read (sort keys %trans1hash){
    if ($trans1hash{$read}=~/remove/ || $trans2hash{$read}=~/remove/){
	print TRANS "$read\tremoved\n";
    } else {
	die "Missing values $read $trans1hash{$read} $trans2hash{$read}\n" unless ($trans2hash{$read});
	die "Missing seqs $read $fasta1hash{$trans1hash{$read}} $fasta2hash{$trans2hash{$read}}\n" unless ($fasta1hash{$trans1hash{$read}} && $fasta2hash{$trans2hash{$read}});
	if ($OTUhash{$trans1hash{$read}}{$trans2hash{$read}}){
	    #this otu alread exists so just record
	    print TRANS "$read\t$OTUhash{$trans1hash{$read}}{$trans2hash{$read}}\n";
	} else {
	    #it doesn't exist so record values
	    $OTUhash{$trans1hash{$read}}{$trans2hash{$read}}="$trans1hash{$read}_$trans2hash{$read}";
	    print TRANS "$read\t$OTUhash{$trans1hash{$read}}{$trans2hash{$read}}\n";
	    print FA ">$trans1hash{$read}_$trans2hash{$read}\n$fasta1hash{$trans1hash{$read}}$fasta2hash{$trans2hash{$read}}\n";
	}
    }
}
