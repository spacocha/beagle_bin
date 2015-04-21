#! /usr/bin/perl -w

die "Usage: fasta\n" unless (@ARGV);
($list) = (@ARGV);
chomp ($list);

$/=">";
open (IN, "<$list" ) or die "Can't open $list\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($newline, @seqs)=split ("\n", $line);
    ($sequence)=join ("", @seqs);
    $hash{$newline}=$sequence;
    (@len)=split ("", $sequence);
    $length=@len;
    $sorthash{$newline}=$length;
}
close (IN);

foreach $iso (sort {$sorthash{$b} <=> $sorthash{$a}} keys %sorthash){
    print ">$iso\n$hash{$iso}\n";
}
