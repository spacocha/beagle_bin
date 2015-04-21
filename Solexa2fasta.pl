#! /usr/bin/perl -w
#
#

	die "Usage: File > output\n" unless (@ARGV);
	($file) = (@ARGV);

	die "Please follow command line args\n" unless ($file);
chomp ($file);
$/="@";

	open (IN, "<$file") or die "Can't open $file\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, $seq, $name2, $useless) =split("\n", $line);
		print ">$name\n$seq\n\n";
       	}
	close (IN);

