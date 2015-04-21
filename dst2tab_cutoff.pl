#! /usr/bin/perl -w
#
#

	die "Use this file with a .dst file from clustal to get a 
pairwise tab del output for 1 isolate 2 isolate dist
Usage: inputfile cutoff_val > Redirect\n" unless (@ARGV);
	($file, $cutoff) = (@ARGV);
	chomp ($file);
	$k=1;
	open (IN, "<$file") or die "Can't open $file\n";
	while ($line=<IN>){
		chomp ($line);
		(@pieces) = split (" ", $line);
		if ($pieces[0] =~/[A-z]/){#start a new entry
			($isolate) = shift (@pieces);
			$j=1;
			$translatehash2{$k}=$isolate;
			$k++;
		}

		foreach $distance (@pieces){
			next unless ($distance && $isolate);
			$isolatehash{$isolate}{$j}=$distance if ($distance <= $cutoff);
			$j++;
		}
		
	}

	foreach $isolate (sort keys %isolatehash){
		foreach $oisono (sort keys %{$isolatehash{$isolate}}){
			next if ($isolate eq $translatehash2{$oisono});
			next if ($done{$isolate}{$translatehash2{$oisono}} || $done{$translatehash2{$oisono}}{$isolate});
			$done{$isolate}{$translatehash2{$oisono}}++;
			print "$isolate\t$translatehash2{$oisono}\t$isolatehash{$isolate}{$oisono}\n";
		}
	}
print "Finished\n";
