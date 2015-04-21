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
		if ($sequence =~//){
			($sequence) =~ s/ //g;
		}

		if ($sequence =~/^t{2,100}/i){
			($edited_sequence) = $sequence =~/^t{2,100}(.+)$/i;
		} else {
			$edited_sequence = $sequence;
		}

		($edit2)=$edited_sequence=~/^....(.+)$/;
		print ">$a[$info]\n$edit2\n\n" if ($a[$info] && $edit2);
	}
	close (IN);
	
