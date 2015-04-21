#! /usr/bin/perl -w
#
#

	die "Use this program to fix errors in sequencing data
It will map low abundance sequences to higher abundance sequences with the following conditions:
Allows for discrepancies between parent and child at a base with a frequency in the data set of less than 0.001
Allows for up to three discrepancies in one child sequence
Usage: tab namecol seqcol> Redirect\n" unless (@ARGV);
	($file2, $namecol, $seqcol) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file2);
chomp ($seqcol);
chomp ($namecol);
$namecolm1=$namecol-1;
$seqcolm1=$seqcol-1;


#make a table of total counts per seed cluster
    open (IN, "<${file2}") or die "Can't open ${file2}\n";
    while ($line = <IN>){
	chomp ($line);
	next unless ($line);
	(@fields) = split ("\t", $line);
	#record position and base information for all of the sequences
	next unless ($fields[$seqcolm1]);
	($sequence) = $fields[$seqcolm1];
	$seqhash{$sequence}++;
	$namehash{$sequence}=$fields[$namecolm1];
	(@pieces)=split ("", $sequence);
	$total = @pieces;
	$i = 0;
	until ($i >= $total){
	    $polyhash{$i}{$pieces[$i]}++;
	    $polyhashtotal{$i}++;
	    $i++;
	}
    }
close (IN);

#set the frequency of each base at each position
foreach $position (keys %polyhash){
    foreach $base (sort keys %{$polyhash{$position}}){
	$polyhashfreq{$position}{$base} = $polyhash{$position}{$base}/$polyhashtotal{$position};
    }
}

#evaluate each sequence compared to the polyhashfreq
foreach $seq (keys %seqhash){
    (@pieces)=split ("", $seq);
    $total = @pieces;
    $i = 0;
    @lowlike=();
    until ($i >= $total){
	$base=$pieces[$i];
	$likely=$polyhashfreq{$i}{$base};
	if ($likely  < 0.0001){
	    #looks for a sequence like it
	    push(@lowlike, $i);
	}
	$i++;
    }
    $divide = @lowlike;
    if ($divide==1){
	$split1=$lowlike[0];
	($first, $wrongbase, $second) = $seq=~/^(.{$split1})(.)(.*)$/;
	foreach $checkseq (sort {$seqhash{$b} <=> $seqhash{$a}} keys %seqhash){
	    next if ($checkseq eq $seq);
	    #only change if the bad seq is < 0.25 of the good seq
	    $ratio=$seqhash{$seq}/$seqhash{$checkseq};
	    next if ($ratio >0.25);
	    if ($checkseq=~/^${first}.${second}$/){
		$clusterhash{$seq}=$checkseq;
	    }
	}
    } elsif ($divide ==2){
	$split1=$lowlike[0];
	$split2=$lowlike[1]-$split1 -1;
	($first, $wrongbase, $second, $wrongbase2, $remain) =$seq=~/^(.{$split1})(.)(.{$split2})(.)(.*)$/;
	foreach $checkseq (sort {$seqhash{$b} <=> $seqhash{$a}} keys %seqhash){
	    next if ($checkseq eq $seq);
	    $ratio=$seqhash{$seq}/$seqhash{$checkseq};
	    next if ($ratio > 0.25);
	    if ($checkseq=~/^${first}.${second}.${remain}$/){
		$clusterhash{$seq}=$checkseq;
	    }
	}
    } elsif ($divide ==3){
        $split1=$lowlike[0];
        $split2=$lowlike[1]-$split1 -1;
	$split3=$lowlike[2]-$split2 - 1 - $split1 -1;
        ($first, $wrongbase, $second, $wrongbase2, $third, $wrongbase3, $remain) =$seq=~/^(.{$split1})(.)(.{$split2})(.)(.{$split3})(.)(.*)$/;
        foreach $checkseq (sort {$seqhash{$b} <=> $seqhash{$a}} keys %seqhash){
            next if ($checkseq eq $seq);
            $ratio=$seqhash{$seq}/$seqhash{$checkseq};
            next if ($ratio > 0.25);
            if ($checkseq=~/^${first}.${second}.${third}.${remain}$/){
		$clusterhash{$seq}=$checkseq;
            }
	}
	
    }
  
}

foreach $seq (keys %clusterhash){
    print "$seq\t$namehash{$seq}\t$clusterhash{$seq}\t$namehash{$clusterhash{$seq}}\n";
}
