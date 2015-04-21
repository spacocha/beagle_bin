#! /usr/bin/perl -w
#
#

	die "Usage:  <migration.tab>  > redirect\n" unless (@ARGV);
	($mine) = (@ARGV);
	chomp ($mine);
	die "Please follow command line args\n" unless ($mine);
	open (IN, "<$mine") or die "Can't open $mine\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		(@pieces) = split ("\t", $line);
		if ($one){
			#this is not the first line
			$i=1;
			$j = @pieces;
			until ($i >= $j){
				$hash{$header[$i]}{$pieces[0]}=$pieces[$i];
				$i++;
			}
		} else {
			(@header) = (@pieces);
			$one++;
		}
		
	}	
	close (IN);
	foreach $habitat (sort keys %hash){
		next unless ($habitat);
		foreach $otherhab (sort keys %hash){
			next unless ($otherhab);
			$h = 0;
			foreach $i (sort keys %{$hash{$habitat}}){
				($p) = $hash{$habitat}{$i};
				($q) = $hash{$otherhab}{$i};
				if (($q > 0) && ($p > 0)){
					$h+=($p*(log($p/$q)));
				} else {
					foreach $j (sort keys %{$hash{$otherhab}}){
						print "I $j\n";
					}
					die "I $i HAB1 $habitat $p\tHAB2 $otherhab $q\t ZERO\n";
					$h+=0;
				}
			}
			print "$habitat\t$otherhab\t$h\n";
			
		}
	}

