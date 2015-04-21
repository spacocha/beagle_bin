#! /usr/bin/perl -w
#
#

	die "Usage: Fasta > Redirect\n" unless (@ARGV);
	($file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file2);

$/=">";

open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, @seqs)=split ("\n", $line);
		$sequence = join ("", @seqs);
		($fshort, $rshort) = $sequence=~/^(.{92}).*(.{80})$/;
		print ">$name\n${fshort}${rshort}\n";
       	}
close (IN);

