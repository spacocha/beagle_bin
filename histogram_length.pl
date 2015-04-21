#! /usr/bin/perl -w

die "Usage: fasta\n" unless (@ARGV);
($new) = (@ARGV);
chomp ($new);

$/=">";
open (IN, "<$new" ) or die "Can't open $new\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs) = split ("\n", $line);
    if ($info=~/^ID[0-9]{7}[A-z]_(.+)$/){
	($count)=$info=~/^ID[0-9]{7}[A-z]_(.+)$/;
    } else {
	$count=1;
    }
    $seq=join ("", @seqs);
    ($front, $good, $back)=$seq=~/^(\.*)([ATCGN-]*)(\.*)$/;
    if ($front){
	$flen=split ("", $front);
    } else{
	$flen=0;
    }
    if ($good){
	$glen=split ("", $good) if ($good);
    } else {
	$glen=0;
    }

    if ($back){
	$rlen=split ("", $back);
    } else {
	$rlen=0;
    }
    $total=$flen+$rlen+$glen;
    $totalhash{$total}+=$count;
    $starthash{$flen}+=$count;
    $end=$flen+$glen;
    $endhash{$end}+=$count;
} 
close (IN);

foreach $len (sort keys %starthash){
    print "Starting Position\t$len\t$starthash{$len}\n";
}

foreach $len (sort keys %endhash){
    print "End Position\t$len\t$endhash{$len}\n";
}

foreach $len (sort keys %totalhash){
    print "Len\t$len\t$totalhash{$len}\n";
}
