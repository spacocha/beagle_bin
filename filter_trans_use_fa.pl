#! /usr/bin/perl -w

die "Usage: trans fasta > Redicted\n" unless (@ARGV);
($trans, $fasta) = (@ARGV);
chomp ($trans);
chomp ($fasta);

open (IN, "<$trans" ) or die "Can't open $trans\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $OTU)=split ("\t", $line);
    push (@{$hash{$OTU}}, $name);
}
close(IN);

$/=">";

open (IN, "<$fasta" ) or die "Can't open $fasta\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @seqs) = split ("\n", $line);
    if (@{$hash{$OTU}}){
	foreach $name (@{$hash{$OTU}}){
	    print "$name\t$OTU\n";
	}
    }
} 
close (IN);

