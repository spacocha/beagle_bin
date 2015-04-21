#! /usr/bin/perl -w

die "Usage: fasta filter_count > Redicted\n" unless (@ARGV);
($new, $thresh) = (@ARGV);
chomp ($new);
chomp ($thresh);
$/=">";
open (IN, "<$new" ) or die "Can't open $new\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs) = split ("\n", $line);
    ($count)=$info=~/^ID[0-9]{7}[A-z]_(.+)$/;
    $seq=join ("", @seqs);
    if ($count>$thresh){
	print ">$info\n$seq\n";
    }
} 
close (IN);

