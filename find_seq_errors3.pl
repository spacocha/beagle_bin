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
	($id1, $abund)=$idplus1=~/^(ID[0-9]+P)_([0-9])+$/;
	($id2, $abund)=$idplus2=~/^(ID[0-9]+P)_([0-9])+$/;
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
foreach $id (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
    @wrongbases=();
    $wrongno=0;
    $seq=$seqhash{$id};
    $qual=$qualhash{$id};
    $stdev=$stdevhash{$id};
    (@bases)=split ("", $seq);
    (@quals)=split ("\t", $qual);
    (@stdevs)=split ("\t", $stdev);
    $j=@bases;
    $k=@quals;
    $l=@stdevs;
    $i=0;
    die "Not equal $id $j $k $l\n" unless ($j==$k && $k==$l);
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

    until ($i >=$j){
	#what is the frequency of this base
	($bp)=$bases[$i];
	($freq)=$bpfreqhash{$i}{$bp};
	($tqual)=$quals[$i];
	if ($freq <0.1 && $tqual=~/[0-9]/){
	    #if this is only 1% of t
	    #what is the difference between the quality of this base an the base before and after?
	    $bqual=();
	    $aqual=();
	    $bi=$i-1;
	    $ai=$i+1;
	    if ($i>0){
		$foundb=();
		until ($foundb){
		    if ($quals[$bi]=~/[0-9]/){
			$bqual=$quals[$bi];
			$foundb=1;
		    } else {
			$bi=-1;
		    }
		}
	    }
	    
	    $founda=();
            until ($founda){
		if ($quals[$ai]=~/[0-9]/){
                    $aqual=$quals[$ai];
                    $founda=1;
		} else {
                    $ai=-1;
		}
	    }  

	    $tqual=$quals[$i];
	    if ($bqual){
		$d1=$bqual-$tqual;
		$d2=$aqual-$tqual;
		$aved=($d1+$d2)/2;
	    } else {
		$aved=$qual-$tqual;
	    }
	    if ($avestd < 10*$aved){
		push (@wrongbases, $i);
	    }
	} elsif ($freq<0.0001){
	    push (@wrongbases, $i);
	}
	$i++;
    }
    #check to see if there are three or fewer possible wrong bases
    $wrongno=0;
    foreach $wrong (@wrongbases){
	$wrongno++;
    }
    if ($wrongno){
	if ($wrongno == 1){
	    ($front, $back)=$seq=~/^(.{${wrongbases[0]}}).(.*)$/;
	    foreach $otherid (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
		next if ($id eq $otherid);
		next unless ($abundhash{$otherid}>$abundhash{$id});
		$oseq=$seqhash{$otherid};
		if ($oseq=~/^${front}.${back}$/){
		    die "$id $seq $otherid $oseq\n";
		}
	    }
	} elsif ($wrongno ==2){
	    $split1 = $wrongno[0];
	    $split2=$wrongno[1]-$split1-1;
	    ($front, $mid, $back)=$seq=~/^(.{$split1}).(.{$split2}).(.*)$/;
	    foreach $oseq (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
		next if ($id eq $otherid);
		next unless ($abundhash{$otherid} > $abundhash{$id});
		$oseq=$seqhash{$otherid};
		if ($oseq=~/^${front}.${mid}.${back}$/){
		    die "$id $seq $otherid $oseq\n";
		}
	    }
	} elsif ($wrongbase ==3){
	    $split1=$wronbase[0];
	    $split2=$wrongbase[1]-$split1-1;
	    $split3=$wronbase[2]-$split2-1-$split1-1;
	    ($front, $mid1, $mid2, $back)=$seq=~/^(.{$split1}).(.{$split2}).(.{$split3}).(.*)$/;
	    foreach $otherid (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
		next if ($otherid eq $id);
		next unless ($abundhash{$otherid}> $abundhash{$id});
		$oseq=$seqhash{$otherid};
		if ($oseq=~/^${front}.${mid1}.${mid2}.${back}$/){
		    die "$id $seq $otherid $seq\n";
		}
	    }
	}
    }
}
