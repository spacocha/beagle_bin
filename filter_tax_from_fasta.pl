#! /usr/bin/perl -w

die "Usage: mat fasta > Redicted\n" unless (@ARGV);
($mat, $new) = (@ARGV);
chomp ($new);
chomp ($mat);

$/=">";

open (IN, "<$new" ) or die "Can't open $new\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs) = split ("\n", $line);
#    if ($info=~/^.+\_[0-9]+$/){
#	($OTU)=$info=~/^(.+)\_[0-9]+$/;
#    } elsif ($info=~/^.+\/ab=[0-9]+\//){
#	($OTU)=$info=~/^(.+)\/ab=[0-9]+\//;
#    } else {
#	$OTU=$info;
#    }
    ($shrtinfo)=$info=~/^(.+?)\s/;
    $hash{$shrtinfo}++;
} 
close (IN);

$/="\n";
$first=1;
open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if ($hash{$OTU}){
	print "$OTU";
	foreach $piece (@pieces){
	    if ($piece=~/\;$/){
		($newpiece)=$piece=~/^(.+)\;$/;
	    } else {
		($newpiece)=$piece;
	    }
	    print "\t$newpiece";
	}
	print "\n";
    }
}


close(IN);
