#! /usr/bin/perl -w

die "Input:
Fasta1- the seqs.fna full name file
Fasta2- the mothur short name file
mappingfile- mapping file
mergecol- the col in the mapping file you want to use to merge, comma sep

Usage: fasta1 fasta2 mappingfile mergecol > redirect\n" unless (@ARGV);

($fasta1, $fasta2, $mapping, $mergecol) = (@ARGV);
chomp ($fasta1);
chomp ($fasta2);
chomp ($mapping);
chomp ($mergecol);
(@mergearray)=split (",", $mergecol);
foreach $col (@mergearray){
    $colm1=$col-1;
    push (@mergearraym1, $colm1);
}

open (IN, "<$mapping" ) or die "Can't open $mapping\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    $merge=();
    foreach $col (@mergearraym1){
	if ($merge){
	    ($merge)="$merge".","."$pieces[$col]";
	} else {
	    ($merge)=$pieces[$col];
	}
    }
    ($lib)=$pieces[0];
    $mergehash{$lib}=$merge;
}

    

$/=">";
open (IN, "<$fasta1" ) or die "Can't open $fasta1\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\n", $line);
    ($shrtOTU)=$OTU=~/^(.+?) ./;
    if ($hash{$shrtOTU}){
	die "Duplicated name $shrtOTU $OTU $hash{$shrtOTU}\n";
    } else {
	$hash{$shrtOTU}=$OTU;
    }

}
close (IN);

open (IN, "<$fasta2" ) or die "Can't open $fasta2\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\n", $line);
    ($sequence)=join ("", @pieces);
    if ($hash{$OTU}){
	($shortname)=$OTU=~/^(.+?)_[0-9]+$/;
	print ">$hash{$OTU} MERGE:${mergehash{$shortname}}\n$sequence\n";
    } else {
	die "Missing name $OTU\n";
    }
}
close (IN);

