#! /usr/bin/perl -w
#
#

	die "Use this file with a .dst file from clustal to get a 
pairwise tab del output for 1 isolate 2 isolate dist
Usage: <inputfile> > Redirect\n" unless (@ARGV);
	($file) = (@ARGV);
	chomp ($file);
	$k=1;
	open (IN, "<$file") or die "Can't open $file\n";
	while ($line=<IN>){
		chomp ($line);
		(@pieces) = split (" ", $line);
		if ($pieces[0] =~/[A-z]/){#start a new entry
			($isolate) = shift (@pieces);
			$j=1;
			$translatehash2{$isolate}=$k;
			$k++;
		}

		foreach $distance (@pieces){
			next unless ($distance && $isolate);
			$isolatehash{$isolate}{$j}=$distance;
			$j++;
		}
		
	}

	foreach $isolate (sort keys %isolatehash){
		foreach $otherisolate (sort keys %translatehash2){
			next if ($isolate eq $otherisolate);
			next if ($done{$isolate}{$otherisolate} || $done{$otherisolate}{$isolate});
			$done{$isolate}{$otherisolate}++;
			print "$isolate\t$otherisolate\t$isolatehash{$isolate}{$translatehash2{$otherisolate}}\n";
		}
	}
