#! /usr/bin/perl
#
#

	die "Use this file to parse fastq files and make a large tab file with the data
Barfile should have unique bar name <tab> rc barcode
Usage: <Solexa File1> <Solexa file2> <Barfile> > redirect\n" unless (@ARGV);
	($file1, $file2, $file3) = (@ARGV);

	die "Please follow command line args\n" unless ($file3);
chomp ($file1);
chomp ($file2);
chomp ($file3);

open (IN2, "<${file3}") or die "Can't open forward file ${file3}\n";
while ($line=<IN2>){
    chomp ($line);
    next unless ($line);
    ($libid, $bar)= split ("\t", $line);
    $libidhash{$bar}=$libid;
}
close (IN2);

$/="@";
$count=1;
$lnum=1;
#open the forward file and save for later

open (IN2, "<${file1}") or die "Can't open forward file ${file1}\n";
	while ($line=<IN2>){
		chomp ($line);
		next unless ($line);
		($header, $sequence, $useless1, $qual)=split("\n", $line);
		($shrt_head) = $header =~/^(.+\#.*.{7})\/1$/;
		$i = 0;
		(@qualscores) = split ("", $qual);
		(@bases) = split ("", $sequence);
		$j = @qualscores;
		until ($i >= $j){
		    $k = $i+1;
		    if ($qualscores[$i] eq "B" || $bases[$i] eq "N"){
                    #this is the beginning of unusable data because you can't use a sequence with either B or N's in it                                                                                          
			last;
			$i++;
		    } else {
			if ($qualscores[$i]=~/[CDEFGHIJKLMN]/ || $qualscores[$k]=~/[CDEFGHIJKLMN]/){
			    #this is two consequetive data points with Phred values below 15
			    last;
			    $i++;
			} else {
			    $i++;
			}
		    }

		}
		if ($i > 75){
		    #I want to have all of the datasets complete
		    #If there aren't 50 good bps get rid of it
		    #Change this if it's not ideal
                    ($hashfull{$shrt_head})=$sequence=~/^([A-z]{$i})/;
		    ($hashfullqual{$shrt_head})=$qual=~/^(.{$i})/;
		    push (@farray, $i);
		}
	    }
	close (IN2);
$count=1;
#open the reverse read and print as fasta
open (IN3, "<$file2") or die "Can't open $file2\n";
while ($line=<IN3>){
    chomp ($line);
    next unless ($line);
    ($header, $sequence, $useless1, $qual)=split("\n", $line);
    ($shrt_head) = $header =~/^(.+\#.*.{7})\/2$/;
    ($bar) = $header =~/^.+\#.*(.{7})\/2$/;
    #Make sure there is good forward sequence
    if ($hashfull{$shrt_head}){
        #igure out where the B's start in $qual
	$i = 0;
	(@qualscores) = split ("", $qual);
	(@bases) = split ("", $sequence);
	$j = @qualscores;
	until ($i >= $j){
	    $k = $i+1;
	        if ($qualscores[$i] eq "B" || $bases[$i] eq "N"){
		    #this is the beginning of bad data
		    last;
		    $i++;
		} else {
		    if ($qualscores[$i]=~/[CDEFGHIJKLMN]/ || $qualscores[$k]=~/[CDEFGHIJKLMN]/){
                        #this is two consequetive data points with Phred values below 15                                                                                              
			last;
			$i++;
		    } else {
			$i++;
		    }

		}
	}
	if ($i > 60){
	    ($rc_seq) = $sequence=~/^([A-z]{$i})/;
	    push (@rarray, $i);
	    ($rseq) = revcomp();
	    ($rc_qual) = $qual=~/^(.{$i})/;
	    ($rqual) = revqual();
	    #now store seq2_rc to get an average size for the reverse read 
	    #($rqual)=$qual=~/^(.{$i})/;
	    #I would have to reverse complement the quality scores if I want to use them
	    #print out header (without forward or reverse)\tfull forward\tForward quality\tfull reverse
	    die "What $bar \n" unless ($libidhash{$bar});
	    print "${shrt_head}\t$libidhash{$bar}\t$hashfull{$shrt_head}\t$hashfullqual{$shrt_head}\t$rseq\t$rqual\n";
	}
    }
}

sub revcomp{
    (@pieces) = split ("", $rc_seq);
    #make reverse complement
    $j = @pieces;
    $j-=1;
    $seq = ();
    until ($j < 0){
	if ($pieces[$j]){
	    if ($pieces[$j] eq "A"){
		$seq = "$seq"."T";
	    } elsif ($pieces[$j] eq "T"){
		$seq = "$seq"."A";
	    } elsif ($pieces[$j] eq "C"){
		$seq = "$seq"."G";
	    } elsif ($pieces[$j] eq "G"){
		$seq = "$seq"."C";
	    } elsif ($pieces[$j] eq "N"){
		$seq = "$seq"."N";
	    } else {
		die "$pieces[$j]\n";
	    }
	} else {
	    die "NO j $j\n";
	}
	$j--;
    }
    return ($seq);
}
sub revqual{
    (@pieces) = split ("", $rc_qual);
    #make reverse                                                                                                                                                                                   
    $j = @pieces;
    $j-=1;
    $seq = ();
    until ($j < 0){
	$seq = "$seq"."$pieces[$j]";
        $j--;
    }
    return ($seq);
}
