#! /usr/bin/perl -w
#
#	Use this program to randomize fasta order
#

	die "Usage: <input_file> Redirect output\n" unless (@ARGV);
	
	chomp (@ARGV);
	($file) = (@ARGV);
	$info2 = ();	
	$/ = ">";
	open (IN, "<$file") or die "Can't open $file\n";
	while ($line1 = <IN>){	
		chomp ($line1);
		next unless ($line1);
		push (@lines, $line1);

	}
	
	close (IN);

	$total = @lines;
	$donenum=0;
	until ($donenum ==$total){
		$rand = int(rand($total));
		$randindex = $rand-1;
		next if ($done{$randindex});
		$done{$randindex}++;
		print ">$lines[$randindex]";
		$donenum++;
	}
