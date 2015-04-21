#! /usr/bin/perl -w
#
#

	die "Usage: File output\n" unless (@ARGV);
	($file, $outputtemp) = (@ARGV);

	die "Please follow command line args\n" unless ($file);
chomp ($file);
$count=1;
$lnum=1;
	open (IN, "<$file") or die "Can't open $file\n";
	while ($line=<IN>){
		chomp ($line);
		@pieces=split("", $line);
		$total=@pieces;
		while ($total){
		    $total=$total-1;
		    if ($pieces[$total] eq "\)"){
			$matching = "rp"."${count}"."rp";
			$unmatched{$count}++;
			$printhash{$lnum}=$matching;
			$lnum++;
			#print "$matching\n";
			$count++;
		    } elsif ($pieces[$total] eq "\)"){
			$last=();
			foreach $match (sort {$b <=>$a} keys %unmatched){
			    if ($last){
				$newunmatched{$match}++;
			    } else{
				$matching = "lp"."$match"."lp";
				$printhash{$lnum}=$matching;
				$lnum++;
				$last++;
			    }
			}
			%unmatched = %newunmatched;
			%newunmatched = ();
		    } else {
			$printhash{$lnum}=$pieces[$total];
			$lnum++;
		    }
		}
       	}
	close (IN);

open (OUT, ">${outputtemp}") or die "Can't open $outputtemp\n";
foreach $lnum (sort {$b <=> $a} keys %printhash){
        print OUT "$printhash{$lnum}";
}
print OUT "\n";
close (OUT);
	
