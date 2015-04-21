#! /usr/bin/perl -w

die "Usage: list line_no fasta > Redicted\n" unless (@ARGV);
($list, $lineno, $new) = (@ARGV);
chomp ($new);
chomp ($list);
chomp ($lineno);

open (IN, "<$list" ) or die "Can't open $list\n";
$linecur=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    if ($linecur eq $lineno){
	(@pieces)=split ("\t", $line);
	foreach $piece (@pieces){
	    $hash{$piece}++;
	}
	last;
    }
    $linecur++;

}
close(IN);

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
	$OTU=$info;
#    }
    if ($hash{$OTU}){
	$seq=join ("", @seqs);
	print ">$OTU\n$seq\n";
    }
} 
close (IN);

