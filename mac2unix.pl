#! /usr/bin/perl -w

	die "You must have a template file temp.fa which will split the lines correctly.
Usage: temp.fa data_file>redirect\n" unless (@ARGV);
($corrfile, $file) = (@ARGV);
chomp ($corrfile);
chomp ($file);

	open (IN, "<$corrfile") or die "Can't open $corrfile\n";
	while ($line = <IN>){
		($whatsit) = $line =~/USETHIS(.+)USETHIS/;
		last;
	}
	close (IN);
		open (IN, "<$file") or die "Can't open $file\n";
		while ($line = <IN>){
			(@try) = split ($whatsit, $line);
			foreach $index (@try){
				print "$index\n";
			}
		}
		print "\n";
		close (IN);

