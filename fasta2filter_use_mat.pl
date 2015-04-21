#! /usr/bin/perl -w

die "Usage: mat fasta filter_count > Redicted\n" unless (@ARGV);
($mat, $new, $thresh) = (@ARGV);
chomp ($new);
chomp ($thresh);

open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if (@headings){
	$total=0;
	foreach $value (@pieces){
	    $total+=$value;
	}
	$hash{$OTU}=$total;
    } else {
	(@headings)=@pieces;
    }
}
close(IN);

$/=">";

open (IN, "<$new" ) or die "Can't open $new\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs) = split ("\n", $line);
    if ($info=~/^.+\_[0-9]+$/){
	($OTU)=$info=~/^(.+)\_[0-9]+$/;
    } else {
	$OTU=$info;
    }
    if ($hash{$OTU}){
	$count=$hash{$OTU};
	if ($count>$thresh){
	    $seq=join ("", @seqs);
	    print ">$OTU\n$seq\n";
	}
    }
} 
close (IN);

