#! /usr/bin/perl -w

die "Usage: fasta tax > redirect\n" unless (@ARGV);
$programname="revert_names_mothur3.pl";

($fasta2, $fasta1) = (@ARGV);
chomp ($fasta1);
chomp ($fasta2);
open (IN1, "<$fasta1" ) or die "Can't open $fasta1\n";
while ($line1 =<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($OTU1, $tax)=split ("\t", $line1);
    $taxhash{$OTU1}=$tax;
}
close (IN1);

$/=">";
open (IN1, "<$fasta2" ) or die "Can't open $fasta2\n";
while ($line1 =<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($OTU1, @seqs)=split ("\n", $line1);
    ($sequence)=join ("", @seqs);
    if ($taxhash{$OTU1}){
	print ">$OTU1\t$taxhash{$OTU1}\n$sequence\n";
    } elsif ($OTU1=~/^.+\t/){
	($something)=$OTU1=~/^(.+)\t/;
	if ($taxhash{$something}){
	    print ">$OTU1\t$taxhash{$something}\n$sequence\n";
	} else {
	    die "Doesn't have a trans $OTU1 $taxhash{$something}\n";
	}
    } else {
	die "Missing $OTU1\n";
    }
}
close (IN1);

