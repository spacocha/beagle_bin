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

open (IN2, "<$file1") or die "Can't open $file1\n";
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
		if ($i > 50){
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

        ($rc_seq) = $sequence=~/^([A-z]{$i})/;
	push (@rarray, $i);
	($hashfullrev{$shrt_head}) = revcomp();
	#now store seq2_rc to get an average size for the reverse read 
	($hashfullrevqual{$shrt_head})=$qual=~/^(.{$i})/;
       }
    }



#now get a median size for full f and r
$flen = @farray;
$rlen = @rarray;

(@nfarray) = sort {$a <=> $b}  (@farray);
(@nrarray) = sort {$a <=> $b} (@rarray);

 $halfflen = int($flen/2);
 $halfrlen = int($rlen/2);

$halfflen1 = $halfflen-1;
$halfrlen1 = $halfrlen-1;
$flen1 = $flen-1;
$rlen1 = $rlen-1;


$fmed = $nfarray[$halfflen1];
$rmed = $nrarray[$halfrlen1];

$letter = "N";
$length = 217 + 172 - $fmed - $rmed;
$Ns = $letter x $length;

open (OUT1, ">${outname}.50") or die "Can't open ${outname}.50\n";
open (OUT2, ">${outname}.f.sol") or die "Can't open ${outname}.f.sol\n";
open (OUT3, ">${outname}.r.sol") or die "Can't open ${outname}.r.sol\n";
open (OUT4, ">${outname}.f.fa") or die "Can't open ${outname}.f.fa\n";
open (OUT5, ">${outname}.r.fa") or die "Can't open ${outname}.r.fa\n";
open (OUT6, ">${outname}.concat") or die "Can't open ${outname}.concat\n";

foreach $shrt_head (keys %hashfull){
    #check to make sure both sides pass the length cutoff of $fmed and $rmed
    $actflen = split ("", $hashfull{$shrt_head});
    $actrlen = split ("", $hashfullrev{$shrt_head});
    if ($actflen >=$fmed && $actrlen >=$rmed){
	($newf50) = $hashfull{$shrt_head}=~/^(.{50})/;
	($newfseq) = $hashfull{$shrt_head}=~/^(.{$fmed})/;
	($newrseq) = $hashfullrev{$shrt_head}=~/(.{$rmed})$/;
	($newfqual) = $hashfullqual{$shrt_head}=~/^(.{$fmed})/;
	($newrqual) = $hashfullrevqual{$shrt_head}=~/(.{$rmed})$/;
	print OUT1 ">$shrt_head\n$newf50\n";
	print OUT2 "\@${shrt_head}/1\n${newfseq}\n+${shrt_head}/1\n$newfqual\n";
	print OUT3 "\@${shrt_head}/2\n${newrseq}\n+${shrt_head}/2\n$newrqual\n";
	print OUT4 ">${shrt_head}\n$newfseq\n";
	print OUT5 ">${shrt_head}\n$newfseq\n";
	print OUT6 ">${shrt_head}\n${newfseq}${Ns}${newrseq}\n";
    }
}

close (IN3);
close (OUT1);
close (OUT2);
close (OUT3);
close (OUT4);
close (OUT5);
close (OUT6);

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
