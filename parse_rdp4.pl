#! /usr/bin/perl -w
#
#

	die "Usage: RDP_file > redirect\n" unless (@ARGV);
	($file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);

chomp ($file2);

$/=">";

open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, $rdp)=split ("\n", $line);
		($newname)=$name=~/^(.+) reverse=/;
		(@seqs) = split (";", $rdp);
		print "$newname";
		foreach $seq (@seqs){
		    ($newseq)=$seq=~/^ *(.+)$/;
		    print ";$newseq";
		}
		print "\n";

       	}
close (IN);

