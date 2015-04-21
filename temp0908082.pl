#! /usr/bin/perl -w

die "Usage: <pop_dir list of file> > redirect" unless (@ARGV);
($dir) = (@ARGV);
chomp ($dir);

open (IN1, "<$dir") or die "Can't open ${dir}\n";
while ($line1 = <IN1>){
    chomp ($line1);
    open (IN, "<./pop_dir/${line1}" ) or die "Can't open ./pop_dir/${line1}\n";
    while ($line =<IN>){
	chomp ($line);
	($isolate, $hab, $pop)= split ("\t", $line);
	$pophash{$line1}{$isolate}=$pop;
	$poparray{$line1}{$pop}{$isolate}++;
#	$pophash2{$isolate}{$line1}=$pop;
#	$habhash{$line1}{$isolate}=$hab;
#	$habhash2{$isolate}{$line1}=$hab;    
    }
    close (IN);
}
close (IN1);

foreach $file (keys %poparray){
    foreach $pop (keys %{$poparray{$file}}){
	#see how many times this population remains together in other files
	foreach $otherfile (keys %poparray){
	    next if ($otherfile eq $file);
	    foreach $otherpop (keys %{$poparray{$otherfile}}){
		$in=();
		$out=();
		foreach $isolate (keys %{$poparray{$file}{$pop}}){
		    if ($poparray{$otherfile}{$otherpop}{$isolate}){
			$in++;	
		    } else {
			$out++;
		    }
		}
		if ($in){
		    #this means that at least some of the isolates are in this population
			#this means that not all the isolates are represented
		    $out =0 unless ($out);
		    $total=$in+$out;
		    $percent=$in/$total;
		    if ($percent > 0.9){
			$alsoin=();
			$alsoout=();
			foreach $otherisolate (keys %{$poparray{$otherfile}{$otherpop}}){
			    if ($poparray{$file}{$otherpop}{$otherisolate}){
			        $alsoin++;
			    } else {
			        $alsoout++;
			    }
			}
			$alsoout=0 unless ($alsoout);
			$alsoin=0 unless ($alsoin);
			$alsototal = $alsoout+$alsoin;
			$alsopercent=$alsoin/$alsototal;
			if ($alsopercent > 0.9){
			    $transfile{$file}{$pop}{$otherfile}=${otherpop};
			}
		    }
		    
		}
	    }

	}
    }
}

foreach $file (keys %transfile){
    foreach $pop (keys %{$transfile{$file}}){
	foreach $otherfile (keys %{$transfile{$file}{$pop}}){
	    print "$file\t$pop\t$otherfile\t$transfile{$file}{$pop}{$otherfile}\n";
	}
    }
}
