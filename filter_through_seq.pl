#! /usr/bin/perl -w

die "Use this to keep sequences that match another set
Usage: file_with_seqs_to_keep fasta_with_more > redirect\n" unless (@ARGV);
($file1, $file2) = (@ARGV);
chomp ($file1);
chomp ($file2);

$/=">";
open (IN, "<$file1" ) or die "Can't open $file1\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs)=split ("\n", $line);
    ($sequence)=join ("", @seqs);
    $hash{$sequence}++;
}

close (IN);

open (IN, "<$file2" ) or die "Can't open $file2\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs)=split ("\n", $line);
    ($sequence)=join ("", @seqs);
    foreach $seq (keys %hash){
	if ($seq=~/$sequence/ || $sequence=~/$seq/){
	    print ">$info\n$sequence\n";
	    last;
	}
    }
}

close (IN);
