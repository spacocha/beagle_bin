#! /usr/bin/perl
#
#

	die "Use this file to parse fastq files and make a large tab file with the data
I'm assuming all entries have the same barcode, provide the lib name
Usage: <Solexa Forward> remove_quals> redirect\n" unless (@ARGV);
	($file1,$removequals) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
chomp ($removequals);

$/="@";
$count=1;
$lnum=1;
#open the forward file and save for later

open (IN2, "<${file1}") or die "Can't open forward file ${file1}\n";
	while ($line=<IN2>){
		chomp ($line);
		next unless ($line);
		($header, $sequence, $useless1, $qual)=split("\n", $line);
		(@qualscores) = split ("", $qual);
		(@bases) = split ("", $sequence);
		$i=0;
		$j = @qualscores;
		until ($i >= $j){
		    if ($qualscores[$i] eq "B" || $bases[$i] eq "N"){
                    #this is the beginning of unusable data because you can't use a sequence with either B or N's in it                                                                                          
			last;
			$i++;
		    } else {
			if ($qualscores[$i]=~/[${removequals}]/){
			    #stop when any value hits the quality score in the command line
			    last;
			    $i++;
			} else {
			    $i++;
			}
		    }

		}
		$i-=1;
		if ($i >= 99){
		    #I want to have all of the datasets complete
		    #If there aren't 64 good bps (shortest acceptable length) get rid of it
		    #Change this if it's not ideal
		    print "\@${header}\n${sequence}\n${useless1}\n${qual}\n";
		}
	    }
	close (IN2);


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
