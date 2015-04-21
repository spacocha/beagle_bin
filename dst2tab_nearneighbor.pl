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
			$translatehash{$k}=$isolate;
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
		$nearestdist = ();
		@nearestneighbor = ();
		foreach $no (sort {$isolatehash{$isolate}{$a} <=> $isolatehash{$isolate}{$b}} keys %{$isolatehash{$isolate}}){
			next if ($isolate eq $translatehash{$no});
			if ($nearestdist){
				if ($nearestdist==$isolatehash{$isolate}{$no}){#the it should be kept as nearest neighbor
					push (@nearestneighbor, $translatehash{$no});
				} elsif ($nearestdist>$isolatehash{$isolate}{$no}){#there is a nearer neighbor
					@nearestneighbor = ();
					push (@nearestneighbor, $translatehash{$no});
					$nearestdist=$isolatehash{$isolate}{$no};
				} else{#it's larger so do nothing
				}
			} else {#it's the first round so set it anyway
				$nearestdist=$isolatehash{$isolate}{$no};
				push (@nearestneighbor, $translatehash{$no});
			}		
		}
		print "$isolate\t$nearestdist";
		foreach $neighbor (@nearestneighbor){
			print "\t$neighbor";
		}
		print "\n";
	}
 
	
