#! /usr/bin/perl -w
#
#

	die "Usage: concat.fa output> Redirect\n" unless (@ARGV);
	($file1, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
chomp ($output);
$/=">";

	open (IN, "<$file1") or die "Can't open $file1\n";
open (OUTF, ">${output}.f") or die "Can't open ${output}.f\n";
open (OUTR, ">${output}.r") or die "Can't open ${output}.r\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($seedname, @seqs)=split ("\n", $line);
		($sequence) = join ("", @seqs);
		die "Not 172 bps: $seedname\n$sequence\n" unless ($sequence =~/^.{46}.{46}.{40}.{40}$/);
		($div1, $div2) = $sequence =~/^(.{92})(.{80})$/;
		print OUTF ">${seedname}\n$div1\n\n";
		print OUTR ">${seedname}\n$div2\n\n";
       	}
	close (IN);
close (OUTF);
close (OUTR);
