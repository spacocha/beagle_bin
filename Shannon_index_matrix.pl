#! /usr/bin/perl -w
#
#

	die "Usage:  matrix  > redirect\n" unless (@ARGV);
	($mine) = (@ARGV);
	chomp ($mine);
	die "Please follow command line args\n" unless ($mine);
	open (IN, "<$mine") or die "Can't open $mine\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		(@pieces) = split ("\t", $line);
		if (@header){
			#this is not the first line
			$i=1;
			$j = @pieces;
			until ($i >= $j){
				$hash{$pieces[0]}{$header[$i]}=$pieces[$i] unless ($header[$i] eq "Lin");
				$totalhash{$pieces[0]}+=$pieces[$i];
				$i++;
			}
		} else {
			(@header) = (@pieces);
		}
		
	}	
	close (IN);
	foreach $habitat (sort {$totalhash{$b} <=> $totalhash{$a}} keys %totalhash){
		next unless ($habitat);
		foreach $otherhab (sort keys %hash){
			next unless ($otherhab);
			next if ($done{$otherhab}{$habitat});
			$done{$otherhab}{$habitat}++;
			$done{$habitat}{$otherhab}++;
			$h = 0;
			foreach $i (sort keys %{$hash{$habitat}}){
			    #each is defined as the portion of the 
			    ($p) = $hash{$habitat}{$i}/$totalhash{$habitat};
			    ($q) = $hash{$otherhab}{$i}/$totalhash{$habitat};
			    if (($q > 0) && ($p > 0)){
				$h+=($p*(log($p/$q)));
			    } else {
				$h+=0;
			    }
			}
			print "$habitat\t$otherhab\t$h\n";
			
		    }
	    }

