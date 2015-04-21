#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: <input_file> Redirect output\n" unless (@ARGV);
	
	chomp (@ARGV);
	($file) = (@ARGV);
	open (IN, "<$file") or die "Can't open $file\n";
	while ($line1 = <IN>){	
		chomp ($line1);
		next unless ($line1);
		($info, $seq)=split ("\t", $line1);
		($keeper1, $keeper2)=$seq=~/^.{1772}(.{20670})(.{20670})/;
		print "$info";
		if ($keeper1=~/\./){
		    print "\tremoved";
		} else {
		    print "\t$keeper1";
		}
		if ($keeper2=~/\./){
		    print "\tremoved\n";
		} else {
		    print "\t$keeper2\n";
		}
	}
	
	close (IN);

