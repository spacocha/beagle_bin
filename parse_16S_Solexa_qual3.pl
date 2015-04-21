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
open (OUT1, ">${outname}.f") or die "Can't open ${outname}.f\n";
open (OUT2, ">${outname}.r") or die "Can't open ${outname}.r\n";
open (OUT3, ">${outname}.concat") or die "Can't open ${outname}.concat\n";
open (IN2, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN2>){
		chomp ($line);
		next unless ($line);
		($header, $sequence, $useless1, $qual)=split("\n", $line);
		($shrt_head) = $header =~/^(.+\#.{7})\/1$/;
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
		if ($i > 50){
		    ($goodseq)=$sequence=~/^([A-z]{50})/;
		    if ($goodseq=~/^[ATCG]+$/){
			$hash1{$shrt_head}=$goodseq;
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
    ($shrt_head) = $header =~/^(.+\#.{7})\/2$/;
    if ($hash1{$shrt_head}){
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
	if ($i > 50){
	    ($rc_seq) = $sequence=~/^([A-z]{50})/;
	    if ($rc_seq=~/^[ATGC]+$/){
		($seq2_rc) = revcomp();
		$total16S = "$hash1{$shrt_head}"."$seq2_rc";
		print OUT1 ">$shrt_head\n$hash1{$shrt_head}\n\n";
		print OUT2 ">$shrt_head\n$rc_seq\n\n";
		print OUT3 ">$shrt_head\n$total16S\n\n";
	    }
	}
    }
}
close (IN3);
close (OUT1);
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
