#! /usr/bin/perl -w
#
#

	die "Usage: mat_file fasta abundance_cut-off\n" unless (@ARGV);
	($mat, $fasta, $abund) = (@ARGV);

	die "Please follow command line args\n" unless ($abund);
	chomp ($mat);
	chomp ($fasta);
chomp ($abund);
	open (IN, "<$mat") or die "Can't open $mat\n";
	while ($line=<IN>){
		chomp ($line);
		($OTU, @abunds) = split ("\t", $line);
		$total=0;
		foreach $num (@abunds){
		    $total=$total+$num;
		}
		$hash{$OTU}=$total;
	}
	close (IN);
$/=">";
open (IN, "<$fasta") or die "Can't open $fasta\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @seqs) = split ("\n", $line);
    ($sequence)=join ("", @seqs);
    print ">$OTU\n$sequence\n" if ($hash{$OTU}>$abund);
}
close (IN);
