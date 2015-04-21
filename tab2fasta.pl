#! /usr/bin/perl -w
#
#

	die "Usage: Tab_File (DNA only) Info_column Seq_Column\n" unless (@ARGV);
	($file, $info, $seq) = (@ARGV);

	die "Please follow command line args\n" unless ($file && $info && $seq);
	chomp ($info);
	chomp ($seq);	
	$info-=1;
	$seq-=1;
	open (IN, "<$file") or die "Can't open $file\n";
	while ($line=<IN>){
		chomp ($line);
		(@a) = split ("\t", $line);
		($sequence) = $a[$seq];
		next unless ($sequence =~/[CATGXN-]/i);
		print ">$a[$info]\n$sequence\n\n" if ($a[$info] && $sequence);
	}
	close (IN);
	
