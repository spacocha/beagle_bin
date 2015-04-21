 #! /usr/bin/perl -w
#
#

	die "Use this program to clean up obvious errors
1.) First, tests for alignment problems and adds lower abundance OTUs to higher ones if they are identical without gaps or fit within one or the other
2.) Looks for obvious errors using position and quality information for things found 1 time
Usage: bp_freq_file align_fa trans_file tab name_col seq_col qual_col output\n" unless (@ARGV);
	($bpfreq, $align, $transfile, $tabfile, $namecol, $seqcol, $qualcol, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($bpfreq);
chomp ($align);
chomp ($transfile);
chomp ($tabfile);
chomp ($namecol);
chomp ($seqcol);
chomp ($qualcol);
chomp ($output);
$namecolm1=$namecol-1;
$seqcolm1=$seqcol-1;
$qualcolm1=$qualcol-1;

print "BP file $bpfreq\n";
#read in bp freqs for each position
$first=1;
    open (IN, "<${bpfreq}") or die "Can't open BP ${bpfreq}\n";
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

open (IN, "<${transfile}") or die "Can't open BP ${transfile}\n";
while ($line = <IN>){
    chomp ($line);
    next unless ($line);
    ($name, $OTU) = split ("\t", $line);
    $transOTUhash{$OTU}=$name;
}
close (IN);

$/=">";
print "Opening align $align\n";
open (INFA, "<${align}") or die "Can't open ALIGN ${align}\n";
#evaluate each sequence compared to the polyhashfreq
while ($faline=<INFA>){
    chomp ($faline);
    next unless ($faline);
    ($id, $seq)=split ("\n", $faline);
    if ($id=~/^(.+)_[0-9]+$/){
	($newid, $abund)=$id=~/^(.+)_([0-9]+)$/;
	$abundhash{$newid}=$abund;
    } else {
	die "Need abundance in the name in the fasta file $id\n";
	$newid=$id;
    }
    $seqhash{$newid}=$seq;
    
}
close (INFA);

#Do alignment mistakes first
open (OUT, ">${output}.res") or die "Can't open $output.res\n";
print "Alignment mistakes\n";
print OUT "Alignment mistakes\n";
foreach $nid (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
    #don't evaluate as a parent if it's already a child
    $gapless2=$seqhash{$nid};
    $gapless2=~s/-//g;
    #check if it's already done
    if (%alignmenthash){
	if ($alignmenthash{$gapless2}){
	    #this sequence is the same as a more abundant (or already done) sequence
	    #check if the alignment is the only difference
	    $oid=$alignmenthash{$gapless2};
	    $id=$nid;
	    print OUT "Changefrom,${id},${oid},Changeto,$id,$oid,Alignment mistake,Done\n";
	    $parenthash{$oid}++;
	    $childhash{$id}++;
	} else {
	    #is it part of another cluster?
	    $captured=0;
	    foreach $gapless3 (sort keys %alignmenthash){
		if ($gapless3=~/$gapless2/){
		    #the new lower abundance sequence is smaller than a more abundant, larger sequence
		    $oid=$alignmenthash{$gapless3};
		    $id=$nid;
		    print OUT "Changefrom,${id},${oid},Changeto,$id,$oid,Alignment mistake:contained,Done\n";
		    $parenthash{$oid}++;
		    $childhash{$id}++;
		    $captured++;
		    last;
		} elsif ($gapless2=~/$gapless3/){
		    #the new lower abundance sequence is larger than a more abundant, smaller sequence
		    $oid=$alignmenthash{$gapless3};
		    $id=$nid;
		    print OUT "Changefrom,${id},${oid},Changeto,$id,$oid,Alignment mistake:Larger,Done\n";
		    $parenthash{$oid}++;
		    $childhash{$id}++;
		    $captured++;
		    last;
		}
	    }
	}	
	#mark as seen
	$alignmenthash{$gapless2}=$nid unless ($captured);
    } else {
	$alignmenthash{$gapless2}=$nid;
    }
    print OUT "$nid: Done testing alignment\n";
}
print OUT "Finished Alignment\n";

print "Getting tab values\n";

$/="\n";
open (IN, "<${tabfile}") or die "Can't open ${tabfile}\n";
while ($line = <IN>){
    chomp ($line);
    next unless ($line);
    (@pieces) = split ("\t", $line);
    ($seq)=$pieces[$seqcolm1];
    ($qual)=$pieces[$qualcolm1];
    ($name)=$pieces[$namecolm1];
    $fullseqhash{$name}=$seq;
    $qhash{$name}=$qual;
}
close (IN);
fastq_mat();
print "Beginning non-alignment analysis\n";
foreach $oid (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
    next if ($abundhash{$oid}>1 || $childhash{$oid});
    #Only one so I can call the name from the transOTUhash
    $name=$transOTUhash{$oid};
    #print OUT "Checking $oid $name\n";
    #now I can get the sequence and the qual
    $fullseq=$fullseqhash{$name};
    $qual=$qhash{$name};
    die "Missing values for NAME: $name SEQ: $fullseq QUAL: $qual\n" unless ($fullseq && $qual);
    $gapless=$seqhash{$oid};
    die "Missing gapless $oid $alignhash{$oid}\n" unless ($gapless);
    $gapless=~s/-//g;
    if ($fullseq=~/^.*${gapless}.*$/){
	($before, $piece, $after)=$fullseq=~/^(.*)(${gapless})(.*)$/;
	#print OUT "$piece\n";
    } else {
	die "Doesn't match $fullseq $gapless\n";
    }
    #how many bases are before the real sequence
    if ($before){
	(@bbases)=split ("", $before);
	$blen=@bbases;
    } else {
	$blen=0;
    }
    #how many bases are in the real seqeunce
    if ($piece){
	(@bases)=split("", $piece);
        $len=@bases;
    } else {
	die "No piece $piece\n";
	$len=0;
    }
    #get the quality scores
    ($squal)=$qual=~/^.{$blen}(.{$len})/;
    #print OUT "Qual: $squal\n";
    (@qbases)=split ("",$squal);
    $qlen=@qbases;
    die "Not equal $len $qlen\n" unless ($len == $qlen);
    $i=0;
    @removebases=();
    $sstring=();
    until ($i >=$len){
	$go=();
	($base)=$bases[$i];
	if ($bpfreqhash{$i}{$base} < 0.001){
	    #print OUT "Found a low freq base $i $bpfreqhash{$i}{$base}\n";
	    #what's the quality of this base and the bases before and/or after it
	    $qscorebase=$qualhash{$qbases[$i]};
	    $k=$i-1;
	    if ($k>=0){
		$qscorebbase=$qualhash{$qbases[$k]};
	    }
	    $j=$i+1;
	    if ($j<$len){
		$qscoreabase=$qualhash{$qbases[$j]};
	    }
	    #is the quality of this base less than 90% of either the base before and/or the base after
	    if ($qscorebase < 10){
		#print OUT "Found a low freq base with qual less than 10: $i $bpfreqhash{$i}{$base} BASE: $qscorebase\n";
		$go++;
		push (@removebases, $i);
	    } else {
		if ($qscorebbase){
		    $bthresh=0.9*$qscorebbase;
		    if ($qscoreabase){
			$athresh=0.9*$qscoreabase;
			if ($qscorebase < $bthresh && $qscorebase < $athresh){
			    #print OUT "Found a low freq base $i $bpfreqhash{$i}{$base} BASE: $qscorebase BEFORE: $qscorebbase AFTER: $qscoreabase\n";
			    #this is a likely error so change it by looking for a sequence that matches it
			    #make the before and after sequence using the bad base
			    $go++;
			    push (@removebases, $i);
			}
		    } else {
			if ($qscorebase < $bthresh){
			    #print OUT "Found a low freq base $i $bpfreqhash{$i}{$base} BASE: $qscorebase Before:$qscorebbase\n";
			    $go++;
			    push (@removebases, $i);
			}
		    }
		} else {
		    if ($qscoreabase){
			$athresh=0.9*$qscoreabase;
			if ($qscorebase <$athresh){
			    #print OUT "Found a low freq base $i $bpfreqhash{$i}{$base} BASE:$qscorebase AFTER:$qscoreabase\n";
			    $go++;
			    push (@removebases, $i);
			}
		    }
		}
	    }
	}
	#print OUT "OK $i $bpfreqhash{$i}{$base} BASE:$qscorebase AFTER:$qscoreabase BEFORE:$qscorebbase\n" unless ($go);
	$i++;
    }
    if (@removebases){
	#get the piece of sequence that is contained between the last error and this one
	$sstring="";
	$beforelen=0;
	foreach $base (@removebases){
	    #figure out what the beginning base is
	    $slen=$base-$beforelen;
	    ($substring)=$gapless=~/^.{$beforelen}(.{$slen})/;
	    $sstring="$sstring"."$substring".".";
	    $beforelen=$base+1;
	    #print "$base $beforelen $slen\n";
	}
	($substring)=$gapless=~/^.{$beforelen}(.*)$/;
	$sstring="$sstring"."$substring";
	%parents=();
	foreach $id (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
	    next if ($id eq $oid || $abundhash{$id}<=1 || $childhash{$id});
	    ($gaplessid)=$seqhash{$id};
	    die "Missing gapless $oid $alignhash{$oid}\n" unless ($gapless);
	    $gaplessid=~s/-//g;
	    if ($gaplessid=~/$sstring/){
		push (@parents, $id);
		#how many bp different are they overall
		(@bases)=split ("", $gaplessid);
		(@obases)=split ("", $gapless);
		$j=@bases;
		$k=@obases;
		#alignments might be different?
		if ($k<$j){
		    $l=$k;
		} else {
		    $l=$j;
		}
		$i=0;
		@mismatch=();
		$kill=();
		until ($i >=$l){
		    die "Bases[$i] $bases[$i] Obases[$i] $obases[$i]\nSeq $gaplessid\nOseq $gapless\n" unless ($bases[$i] && $obases[$i]);
		    unless ($bases[$i] eq $obases[$i]){
			$base=$bases[$i];
			$obase=$obases[$i];
			($basefreq)=$bpfreqhash{$i}{$base};
			($obasefreq)=$bpfreqhash{$i}{$obase};
			if ($basefreq >= $obasefreq){
			    push (@mismatch, $i);
			} else {
			    #print "Not a good change $basefreq $obasefreq $id $base $oid $obase\n";
			    $kill++;
			}
		    }
		    $i++;
		}
		$mismatches=@mismatch;
		if ($kill){
		    #don't evaluate as parent because it's not a good enough change
		} else {
		    print OUT "Changefrom,${oid},${id},Changeto,${oid},${id},Mismatches at ${mismatches} low quality bases,Done\n";
		    last;
		}
	    }
	}
    }
    print OUT "$oid: Done testing as child\n";
}

print OUT "Finished\n";
close (OUT);

sub fastq_mat{
    %qualhash=("B", "0", "C", "3", "D", "4", "E", "5", "F", "6", "G", "7", "H", "8", "I", "9", "J", "10", "K", "11", "L", "12", "M", "13", "N", "14", "O", "15", "P", "16", "Q", "17", "R", "18", "S", "19", "T", "20", "U", "21", "V", "22", "W", "23", "X", "24", "Y", "25", "Z", "26", "[", "27", "\\", "28", "]", "29", "^", "30", "_", "31", "`", "32", "a", "33", "b", "34", "c", "35", "d", "36", "e", "37", "f", "38", "g", "39", "h", "40", "i", "41");
}
