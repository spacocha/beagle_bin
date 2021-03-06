#! /usr/bin/perl -w
#
#

	die "Use this program to fix errors in sequencing data
It will map low abundance sequences to higher abundance sequences with the following conditions:
Allows for discrepancies between parent and child at a base with a frequency in the data set of less than 0.001
Allows for up to three discrepancies in one child sequence
Usage: bp_freq_file align_fa qual_file stdv_file> Redirect\n" unless (@ARGV);
	($bpfreq, $align, $qual, $stdev) = (@ARGV);

	die "Please follow command line args\n" unless ($stdev);
chomp ($bpfreq);
chomp ($align);
chomp ($qual);
chomp ($stdev);

#read in bp freqs for each position
$first=1;
    open (IN, "<${bpfreq}") or die "Can't open ${bpfreq}\n";
    while ($line = <IN>){
	chomp ($line);
	next unless ($line);
	($position, @bases) = split ("\t", $line);
	#record position and base information for all of the sequences
	if ($first){
	    (@headers)=@bases;
	    $first=();
	} else {
	    $i=0;
	    $j=@bases;
	    until ($i >=$j){
		$bpfreqhash{$position}{$headers[$i]}=$bases[$i];
		$i++;
	    }
	}
    }
close (IN);

$/=">";
open (INFA, "<${align}") or die "Can't open ${align}\n";
open (INQUAL, "<${qual}") or die "Can't open ${qual}\n";
open (INSTDEV, "<${stdev}") or die "Can't open ${stdev}\n";
#evaluate each sequence compared to the polyhashfreq
$first=1;
while ($faline=<INFA>){
    $qualine=<INQUAL>;
    $stdevline=<INSTDEV>;
    chomp ($faline);
    chomp ($qualine);
    chomp ($stdevline);
    if ($first){
	$first=();
    } else {
	($id, $seq)=split ("\n", $faline);
	($idplus1, $qual)=split ("\n", $qualine);
	($idplus2, $stdev)=split ("\n", $stdevline);
	($id1, $abund)=$idplus1=~/^(ID[0-9]+P)_([0-9]+)$/;
	($id2, $abund)=$idplus2=~/^(ID[0-9]+P)_([0-9]+)$/;
	die "Not the same files $id $id1 $id2\n" unless ($id eq $id1 && $id1 eq $id2);
	$seqhash{$id}=$seq;
	$abundhash{$id}=$abund;
	$qualhash{$id}=$qual;
	$stdevhash{$id}=$stdev;
    }
}
close (INFA);
close (INQUAL);
close (INSTDEV);
foreach $id (sort {$abundhash{$a} <=> $abundhash{$b}} keys %abundhash){
    next if ($parenthash{$id});
    foreach $oid (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
	#only evaluate things that are at higher abundances than id and not already changed
	next if ($id eq $oid || $abundhash{$id}*2 > $abundhash{$oid} || $childhash{$oid});
	%keepqual=();
	%keepfreq=();
	$seq=$seqhash{$id};
	$oseq=$seqhash{$oid};
	(@bases)=split ("", $seq);
	(@obases)=split ("", $oseq);
	$j=@bases;
	$i=0;
	@mismatch=();
	until ($i >=$j){
	    unless ($bases[$i] eq $obases[$i]){
		push (@mismatch, $i);
	    }
	    $i++;
	}
	$mismatches=@mismatch;
	%warning=();
	if ($mismatches <=3){
	    #these sequences are close (less than 3 mismatches)
	    #see if there is a chance that the mismatch is due to seq error
	    #what is the frequency of mismatch bases
	    foreach $i (@mismatch){
		$base=$bases[$i];
		$obase = $obases[$i];
		$freq=$bpfreqhash{$i}{$base};
		$ofreq=$bpfreqhash{$i}{$obase};
		if ($freq*2 >=$ofreq){
		    $warning{$i}{"freq"}="BAD: ID base $i $base is more frequent ($freq) than ODI ($ofreq)";
		} else {
		    $warning{$i}{"freq"}="GOOD: ID base $i $base is less frequent ($freq) than OID ($ofreq)";
		    $keepfreq{$i}++;
		}
	    }
	    #what is the difference in quality of each potentially wrong base
	    $qual=$qualhash{$id};
	    $stdev=$stdevhash{$id};
	    (@quals)=split ("\t", $qual);
	    (@stdevs)=split ("\t", $stdev);
	    $l=@quals;
	    $stdsum=0;
	    $stdtotal=0;
	    foreach $std (@stdevs){
		next unless ($std=~/[0-9]/);
		if ($stdsum){
		    $stdsum+=$std;
		} else {
		    $stdsum=$std;
		}
		$stdtotal++;
	    }
	    $avestd=$stdsum/$stdtotal if ($stdtotal);

	    foreach $i (@mismatch){
		if ($quals[$i]=~/[0-9]/){
		    $bi=$i-1;
		    $ai=$i+1;
		    if ($bi > -1){
			$foundb=();
			until ($foundb){
			    if ($quals[$bi]=~/[0-9]/){
				$bqual=$quals[$bi];
				$foundb=1;
			    } else {
				$bi-=1;
			    }
			}
		    }
		    if ($ai < $j){
			$founda=();
			until ($founda){
			    if ($quals[$ai]=~/[0-9]/){
				$aqual=$quals[$ai];
				$founda=1;
			    } else {
				$ai+=1;
			    }
			}
		    }
		    if ($abundhash{$id}==1){
			if ($bqual > $quals[$i] && $aqual > $quals[$i]){
			    $warning{$i}{"qual"}="GOOD: This base has lower quality $i $bqual => $quals[$i] <= $aqual";
			    $keepqual{$i}++;
			} else {
			    $warning{$i}{"qual"}="BAD: This base is not lower quality $i $bqual => $quals[$i] <= $aqual";
			}
		    } else {
			$difsum=0;
			$diftotal=0;
			if ($bqual){
			    $difsum+=($bqual-$quals[$i]);
			    $diftotal++;
			}
			if ($aqual){
			    $difsum+=($aqual-$quals[$i]);
			    $diftotal++;
			}
			$aved=$difsum/$diftotal;
			if ($aved*10 > $avestd){
			    $warning{$i}{"qual"}="GOOD: This base has lower quality $i $bqual => $quals[$i] <= $aqual";
			    $keepqual{$i}++;
			} else {
			    $warning{$i}{"qual"}="BAD: This base is not lower quality $i $bqual => $quals[$i] <= $aqual";
			}
		    }
		} else {
		    $warning{$i}{"qual"}="GOOD: This base is a gap $i\n";
		    $keepqual{$i}++;
		}
	    }
	    $throw=0;
	    foreach $i (sort {$a <=> $b} keys %warning){
		$throw=1 unless ($keepqual{$i} || $keepfreq{$i});
		#foreach $val (sort keys %{$warning{$i}}){
		 #   print "$id $oid: $warning{$i}{$val}\n";
		    #foreach value, keep if either the freq or qual suggests it's wrong
		#}
	    }
	    unless ($throw){
		print "Change $id => $oid\n";
		#when it's assigned as a parent, don't evalualte as a child
		$parenthash{$oid}++;
		#when it's assigned as a child, don't evaluate as a parent
		$childhash{$id}++;
		foreach $i (sort {$a <=> $b} keys %warning){
		    foreach $val (sort keys %{$warning{$i}}){
			print "$id $oid: $warning{$i}{$val}\n";
		    }
		}
		last;
	    }
	}
    }
}

 
