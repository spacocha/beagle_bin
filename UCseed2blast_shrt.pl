#! /usr/bin/perl -w
#
#

	die "Usage: seed.fa (sequences need to be even number)> Redirect\n" unless (@ARGV);
	($file1) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
$/=">";

	open (IN, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($seedname, @seqs)=split ("\n", $line);
		($sequence) = join ("", @seqs);
		(@pieces) = split ("", $sequence);
		$total = @pieces;
		$half=$total/2;
		die "Not half, $total $half\n" unless ($sequence=~/^.{$half}.{$half}$/);
		($first, $sec) = $sequence=~/^(.{$half})(.{$half})$/;
		print ">${seedname}_1\n$first\n\n";
		print ">${seedname}_2\n$sec\n\n";
       	}
	close (IN);
