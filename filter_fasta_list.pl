#! /usr/bin/perl -w

die "Use this with uchime or OTU lists to filter a fasta to only those you want to keep
Use \"err\" as type for the OTU list from err files where each OTU has the parent
in the first column and other children listed next
Use \"uchime\" as type for results of uchime, keeps only lines that don't end in Y 
Usage: list fasta type > redirect\n" unless (@ARGV);
($tab, $fasta, $type) = (@ARGV);
chomp ($tab);
chomp ($fasta);
chomp ($type);
open (IN, "<$tab" ) or die "Can't open $tab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    if ($type eq "err"){
	(@pieces)=split ("\t", $line);
	$hash{$pieces[0]}++;
    } elsif ($type eq "uchime"){
	#don't record values that are predicted chimeras
	next unless ($line=~/Y$/);
	($number, $OTUplus, @pieces)=split ("\t", $line);
	($OTU)=$OTUplus=~/^(.+)\/ab=/;
	$removehash{$OTU}++;
    } else {
	die "I don't know your type $type\n";
    }
}
close (IN);

$/=">";
open (IN, "<$fasta" ) or die "Can't open $fasta\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, $seq)=split ("\n", $line);
    unless ($removehash{$OTU}){
	print ">$OTU\n$seq\n";
    }
}
close (IN);
