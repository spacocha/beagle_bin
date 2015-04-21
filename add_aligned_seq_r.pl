#! /usr/bin/perl -w
#
#

	die "Usage: aligned_file tab_file threshold namecol log stat > Redirect\n" unless (@ARGV);
	($file2, $file3, $thresh, $namecol, $log, $stat) = (@ARGV);

	die "Please follow command line args\n" unless ($thresh);
chomp ($file2);
chomp ($file3);
chomp ($thresh);
chomp ($namecol);
chomp ($log);
chomp ($stat);

$namecolm1 = $namecol-1;
$/ = ">";
$total=0;
open (LOG, ">>$log") or die "Can't open $log\n";
open (STAT, ">>$stat") or die "Can't open $stat\n";
open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, @seqs)=split ("\n", $line);
		next unless ($name);
		$sequence = join ("", @seqs);
		$hash{$name}=$sequence;
		#stop at conserved stopping points in reverse read
		($full)=$sequence=~/^(.{201})/;
                ($med1)=$sequence=~/^.{29}(.{172})/;
                ($med2)=$sequence=~/^.{66}(.{135})/;
                ($shrt)=$sequence=~/^.{87}(.{114})/;
		if ($full=~/^[AGCT-]+$/){
		    #if there are no gaps (.) in this sequence, record as plus
		    $longno++;
		} 
		if ($med1=~/^[AGCT-]+$/){
                    #if there are no gaps (.) in this sequence, record as plus                                                                                                                                 
		    $med1no++;
		}
                if ($med2=~/^[AGCT-]+$/){
                    #if there are no gaps (.) in this sequence, record as plus  
		    $med2no++;
		}

		if ($shrt=~/^[AGCT-]+$/){
                    #if there are no gaps (.) in this sequence, record as plus                                                                                                                                 
		    $shrtno++;
		}
		$total++;

       	}
close (IN);

$longper = 100*$longno/$total;
$med1per = 100*$med1no/$total;
$med2per = 100*$med2no/$total;
$shrtper = 100*$shrtno/$total;

if ($longper >= $thresh){
    $drop=0;
    $keeplen = 201;
} elsif ($med1per >= $thresh){
    $drop=29;
    $keeplen = 172;
} elsif ($med2per >= $thresh){
    $drop=66;
    $keeplen = 1135;
} elsif ($shrtper >=$thresh) {
    $drop=87;
    $keeplen = 114;
} else {
    die "Your threshold value is not met Short: $shrtper\n";
}
print LOG "Keep length for reverse sequence is: $drop $keeplen\n";

$/ = "\n";
$total=0;
open (IN, "<$file3") or die "Can't open $file3\n";
        while ($line=<IN>){
                chomp ($line);
                next unless ($line);
                (@linepieces)=split ("\t", $line);
		if ($hash{$linepieces[$namecolm1]}){
		    if ($hash{$linepieces[$namecolm1]} eq "removed"){
			$ralign="removed";
		    } else {
			#this sequence aligned
			($newseq)=$hash{$linepieces[$namecolm1]}=~/^.{$drop}(.{$keeplen})/;
			if ($newseq=~/^[ATGC-]+$/){
			    #it only has good stuff
			    $ralign=$newseq;
			} else {
			    $ralign="removed";
			    $removelen++;
			    print STAT "$name: removed because reverse align len is short\n";
			}
		    }
		} else {
		    #does not get retained because it did not align
		    $ralign="removed";
		    $removealn++;
		    print STAT "$name: removed because reverse did not align\n";
		}
		$first=1;
		foreach $piece (@linepieces){
		    if ($first){
			print "$piece";
			$first=();
		    } else {
			print "\t$piece";
		    }
		}

		print "\t$ralign\n";
	    }
close (IN);
close (LOG);
close (STAT);

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
	    } elsif ($pieces[$j] eq "-"){
		$seq = "$seq"."-";
	    } else {
		die "RC NO Piece: $pieces[$j] $rc_seq\n";
	    }
	} else {
	    die "NO j $j\n";
	}
	$j--;
    }
    return ($seq);
}
