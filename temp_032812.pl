#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: <input_file> <size> > Redirect output\n" unless (@ARGV);
	

	($file, $size) = (@ARGV);
chomp ($file);
chomp ($size);

	$/ = "@";
	open (IN, "<$file") or die "Can't open $file\n";
	while ($line1 = <IN>){	
		chomp ($line1);
		next unless ($line1);
		$seq = ();
		($info, $seq, $name, $qual) = split ("\n", $line1);
		($new) = $seq=~/(.{$size}).$/;
		($newqual)=$qual=~/(.{$size}).$/;
		print ">${info}\n$new\n";

	}
	
	close (IN);

	
