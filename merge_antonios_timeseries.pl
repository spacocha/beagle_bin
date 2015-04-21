#! /usr/bin/perl -w

die "Usage: mat output> redirect\n" unless (@ARGV);

($mat, $output)=(@ARGV);
chomp ($mat);
chomp ($output);

#make the replciate hash
%rephash = (
        22 => '1um',
        23 => '1um',
        24 => '1um',
        25 => '2um',
        26 => '2um',
        27 => '2um',
        19 => '5um',
        20 => '5um',
        21 => '5um',
        13 => '63um',
        14 => '63um',
        15 => '63um',	 
        37 => 'unfrac',
        38 => 'unfrac',
        39 => 'unfrac',
);

$first=1;
$mergeno=1;
open (TRANS, ">${output}.trans") or die "Can't open ${output}.trans\n";
open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if ($first){
	(@headers)=@pieces;
	$i=0;
	$j=@pieces;
	until ($i >= $j){
	    if ($pieces[$i]=~/^.+\.([0-9]+)\.[0-9]+/){
		($num)=$pieces[$i]=~/^.+\.([0-9]+)\.[0-9]+/;
		$nohash{$num}{$i}=$pieces[$i];
	    } else {
		if ($negativeno){
		    $mergehash{$i}=$negativeno;
		    print TRANS "$mergeno\t$pieces[$i]\t$i\t$pieces[$i]\n";
		} else {
		    $negativeno=$mergeno;
		    $mergehash{$i}=$negativeno;
                    print TRANS "$mergeno\t$pieces[$i]\t$i\t$pieces[$i]\n";
		    $mergeno++;
		}
	    }
	    $i++;
	}
	$first=0;
	#I have all of the numbers, not figure out what to do with them
	$countno=1;
	foreach $num (sort {$a <=> $b} keys %nohash){
	    if ($countno>5){
		$mergeno++;
		$countno=1;
	    } else {
		$countno++;
	    }
	    foreach $i (keys %{$nohash{$num}}){
		print TRANS "$mergeno\t$num\t$i\t$nohash{$num}{$i}\n";
		$mergehash{$i}=$mergeno;
	    }
	}
    } else {
	$i=0;
	$j=@pieces;
	until ($i >=$j){
	    if ($mergehash{$i}){
		if ($headers[$i]){
		    ($repno)=$headers[$i]=~/\.([0-9][0-9])$/;
		    if ($repno){
			if ($rephash{$repno}){
			    $finalhash{$OTU}{$mergehash{$i}}{$rephash{$repno}}+=$pieces[$i];
			    die "Over $mergehash{$i} $i\n" if ($mergehash{$i} > 20);
			    $totalmergeno{$mergehash{$i}}++;
			    $totalname{$rephash{$repno}}++;
			} else {
			    die "Missing rephash for $repno\n";
			}
		    } else {
			$finalhash{$OTU}{$mergehash{$i}}{$headers[$i]}+=$pieces[$i];
		    }
		} else {
		    die "No header $headers[$i] $i $mergehash{$i}\n";
		}
	    } else {
		die "No $mergehash{$i} $i $headers[$i]\n";   
	    }
	    $i++;
	}

    }
}
close (IN);
close (TRANS);
open (OUT, ">${output}.mat") or die "Can't open ${output}.mat\n";

print OUT "OTU";
foreach $n (sort keys %totalname){
    foreach $m (sort {$a <=> $b} keys %totalmergeno){
	print OUT "\t${n}_${m}";
    }
}
print OUT "\n";


foreach $OTU (sort keys %finalhash){
    print OUT "$OTU";
    foreach $name (sort keys %totalname){
	foreach $mergeno (sort {$a <=> $b} keys %totalmergeno){
	    if ($finalhash{$OTU}{$mergeno}{$name}){
		print OUT "\t$finalhash{$OTU}{$mergeno}{$name}";
	    } else {
		print OUT "\t0";
	    }
	}
    }
    print OUT "\n";
}

close (OUT);
