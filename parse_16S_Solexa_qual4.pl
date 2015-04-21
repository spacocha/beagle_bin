#! /usr/bin/perl
#
#

	die "Usage: <Solexa File1> <Solexa file2> <output name>\n" unless (@ARGV);
	($file1, $file2, $outname) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file1);
chomp ($file2);


$/="@";
$count=1;
$lnum=1;
#open the forward file and save for later

open (OUTF92, ">${outname}.f92") or die "Can't open ${outname}.f92\n";
open (OUT2, ">${outname}.r") or die "Can't open ${outname}.r\n";
open (OUT3, ">${outname}.concat") or die "Can't open ${outname}.concat\n";
open (IN2, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN2>){
		chomp ($line);
		next unless ($line);
		($header, $sequence, $useless1, $qual)=split("\n", $line);
		($shrt_head) = $header =~/^(.+\#.*.{7})\/1$/;
		$i = 0;
		(@qualscores) = split ("", $qual);
		$j = @qualscores;
		until ($i >= $j){
		    $k = $i+1;
		    if ($qualscores[$i] eq "B"){
                    #this is the beginning of unusable data                                                                                          
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
		if ($i > 92){
		    #I want to have all of the datasets complete
		    #If there aren't 92 good bps, I don't want 63 either
		    #Change this if it's not ideal
		    ($goodseq92)=$sequence=~/^([A-z]{92})/;
		    if ($goodseq92=~/^[ATCG]+$/){
			$hash92{$shrt_head}=$goodseq92;

		    }
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
    if ($hash92{$shrt_head}){
        #igure out where the B's start in $qual
	$i = 0;
	(@qualscores) = split ("", $qual);
	$j = @qualscores;
	until ($i >= $j){
	    $k = $i+1;
	        if ($qualscores[$i] eq "B"){
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

	if ($i > 80){
	    ($rc_seq) = $sequence=~/^([A-z]{80})/;
	    if ($rc_seq=~/^[ATGC]+$/){
		($seq2_rc) = revcomp();
		$total16S = "$hash92{$shrt_head}"."$seq2_rc";
                print OUTF92 ">$shrt_head\n$hash92{$shrt_head}\n\n";
		print OUT2 ">$shrt_head\n$seq2_rc\n\n";
		print OUT3 ">$shrt_head\n$total16S\n\n";
	    }
	}
    }
}
close (IN3);
close (OUTF92);
close (OUT2);
close (OUT3);

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
