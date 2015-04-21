#! /usr/bin/perl -w

die "Usage: merge_table.txt fasta FileName> redirect\n" unless (@ARGV);
($merge, $mat, $pos) = (@ARGV);
chomp ($merge);
chomp ($mat);
chomp ($pos);

$first=1;
open (IN, "<$merge" ) or die "Can't open $merge\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    if ($pieces[0] eq $pos){
	$hash{$pieces[1]}=$pieces[2];
    }
	
}

close (IN);

open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if ($hash{$OTU}){
	print "$hash{$OTU}";
	foreach $piece (@pieces){
	    print "\t$piece";
	}
	print "\n";
    } else {
	die "Doesn't have a translation $OTU $hash{$OTU}\n";
    }
}
