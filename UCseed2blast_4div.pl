#! /usr/bin/perl -w
#
#

	die "Usage: UC_seed_fa > Redirect\n" unless (@ARGV);
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
		die "Not 172 bps: $seedname\n$sequence\n" unless ($sequence =~/^.{46}.{46}.{40}.{40}$/);
		($div1, $div2, $div3, $div4) = $sequence =~/^(.{46})(.{46})(.{40})(.{40})$/;
		print ">${seedname}_1\n$div1\n>${seedname}_2\n$div2\n>${seedname}_3\n$div3\n>${seedname}_4\n$div4\n";
       	}
	close (IN);

