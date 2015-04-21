#! /usr/bin/perl -w

die "Usage: tab_file seqcol > redirect" unless (@ARGV);
($tab, $seqcol) = (@ARGV);
chomp ($tab);
chomp ($seqcol);
($seqcolm1)=$seqcol-1;

open (IN, "<$tab" ) or die "Can't open $tab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces) = split ("\t", $line);
    die "No seq $pieces[$seqcolm1] $seqcolm1 $line\n" unless ($pieces[$seqcolm1]);
    next if ($pieces[$seqcolm1]=~/remove/);
    $hash{$pieces[$seqcolm1]}++;
} 
close (IN);

$count=1;
foreach $seq (sort {$hash{$b} <=> $hash{$a}} keys %hash){
    (@pieces) = split ("", $count);
    $these = @pieces;
    $zerono = 7 - $these;
    $zerolet = "0";
    $zeros = $zerolet x $zerono;
    print ">ID${zeros}${count}P\n$seq\n";
    $count++;
}
