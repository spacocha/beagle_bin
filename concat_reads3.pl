#! /usr/bin/perl
#
#

	die "Usage: <fasta1> <fasta2> > redirect\n" unless (@ARGV);
	($file1, $file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
chomp ($file2);

$/=">";

open (IN1, "<$file1") or die "Can't open $file1\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($header1, @seqs)=split("\n", $line1);
    ($sequence)=join ("", @seqs);
    ($matching)=$header1=~/^.+_[0-9]+ (.+)\/[1-2] /;
    $hash1{$matching}=$sequence;
}
close (IN1);

create_amb();

open (IN1, "<$file2") or die "Can't open $file2\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($header1, @seqs)=split("\n", $line1);
    ($rc_seq)=join ("", @seqs);
    ($sequence)=revcomp($rc_seq);
#    print "seq $sequence\n";
    die "Missing $sequence\n" unless ($sequence=~/^[A-z]+$/);
    ($matching)=$header1=~/^.+_[0-9]+ (.+)\/[1-2] /;
    $totalfile2++;
    if ($hash1{$matching}){
	$totalmatch++;
	#print "MATCHING $matching\n";
	#theres a matching one in the other file, join them
	#first, see whether one completely overlaps the other
	$sequence1=$hash1{$matching};
	#print "sequence $sequence \nsequence1 $sequence1\n";
	if ($sequence1=~/$sequence/){
	    print ">$header1 contained\n$sequence1\n";
	} elsif ($sequence=~/$sequence1/){
	    print ">$header1 contained\n$sequence\n";
	} else{
	    #check to see if they are similar, but one is within the other
	    $concatseq=();
	    ($concatseq)=find_overlap();
	    if ($concatseq){
		if ($concatseq=~/^[A-z]+$/){
		    print ">$header1 overlap\n${concatseq}\n";
		    $totalmatch++;
		} else {
		    die "Concatseq is weird $concatseq\n";
		}
	    }
	}
    } else {
	$nonmatchingpairs++;
    }
}
close (IN1);

die "Total in file2 $totalfile2
Total matching $totalmatch
Total non-matching $nonmatchingpairs\n";

sub find_overlap{

    $string=();
    #don't overlap less than 5 bo at the end
    $i=5;
    (@pieces1)=split ("", $sequence1);
    (@pieces2)=split ("", $sequence);
    $j=@pieces1;
    $k=@pieces2;
    if ($j < $k){
	$useit=$j;
    } else {
	$useit=$k;
    }
 #   print "useit $useit\n";
    until ($useit <= $i){
	($overlap1)=$sequence1=~/^(.{$useit})/;
	($overlap2)=$sequence=~/(.{$useit})$/;
	#print "sequence1 $overlap1 sequence $overlap2\n";
	if ($overlap1 eq $overlap2){
	    #print "Great $overlap1 $overlap2\n";
	    #they match so keep it
	    ($beginning)=$sequence=~/^(.*).{$useit}$/;
	    ($end)=$sequence=~/^.{$useit}(.*)$/;
	    ($string)="${beginning}${overlap1}${end}";
	    #print "STRING $string\n";
	    return ($string);
	    last;
	} else {
	    ($overlap1)=$seqeunce1=~/(.{$useit})$/;
	    ($overlap2)=$sequence=~/^(.{$useit})/;
	    if ($overlap1 eq $overlap2){
		#print "Great2 $overlap1 $overlap2\n";
		($beginning)=$sequence1=~/^(.*).{$useit}$/;
		($end)=$sequence=~/^.{$useit}(.*)$/;
		($string)="$beginning"."$overlap1"."$end";
		#print "STRING2 $string\n";
		#die "$string\n";
		return ($string);
		last;
	    }
	}
	$useit--;
    }
    if ($j < $k){
        $useit=$j;
    } else {
        $useit=$k;
    }    
    until ($useit <= $i){
        ($overlap1)=$sequence1=~/(.{$useit})$/;
        ($overlap2)=$sequence=~/^(.{$useit})/;
        #print "sequence1 $overlap1 sequence $overlap2\n";
        if ($overlap1 eq $overlap2){
            #print "Great $overlap1 $overlap2\n";
            #they match so keep it                                                                                                                                                                               
            ($beginning)=$sequence=~/^(.*).{$useit}$/;
            ($end)=$sequence=~/^.{$useit}(.*)$/;
            ($string)="${beginning}${overlap1}${end}";
            #print "STRING $string\n";
            return ($string);
            last;
        } else {
            ($overlap1)=$seqeunce1=~/(.{$useit})$/;
            ($overlap2)=$sequence=~/^(.{$useit})/;
            if ($overlap1 eq $overlap2){
                #print "Great2 $overlap1 $overlap2\n";
                ($beginning)=$sequence1=~/^(.*).{$useit}$/;
                ($end)=$sequence=~/^.{$useit}(.*)$/;
                ($string)="$beginning"."$overlap1"."$end";
                #print "STRING2 $string\n";                                                                                                                                                                      
                #die "$string\n";
                return ($string);
                last;
            }
        }
        $useit--;
    }

    return ();
}

sub checkclose{
    $clstring=();
    $string=();
    #they don't match, see if it's close
    (@clbases1)=split ("", $overlap1);
    (@clbases2)=split ("", $overlap2);
    $inc=0;
    $id=0;
    until ($inc >=$useit){
	if ($clbases1[$inc] eq $clbases2[$inc]){
	    $id++;
	}
	$inc++;
    }
    ($percent)=$id/$useit;
    if ($percent>0.95){
	die "I found a close one $percent\n";
	$createoverlap=();
	$inc=0;
	until ($inc >=$useit){
	    if ($bases1[$inc] eq $bases2[$inc]){
		if ($createoverlap){
		    $createoverlap="$createoverlap"."$bases1[$inc]";
		} else {
		    $createoverlap = $bases1[$inc];
		}
	    } else {
		if ($ambhash2{$bases1[$inc]}{$bases2[$inc]}){
		    if ($createoverlap){
			$createoverlap="$createoverlap"."$ambhash2{$bases1[$inc]}{$bases2[$inc]}";
		    } else {
			$createoverlap=$ambhash2{$bases1[$inc]}{$bases2[$inc]};
			    }
		} else {
		    die "Missing $bases1[$inc] $bases2[$inc] from $ambhash2\n";
			}
	    }
	    $inc++;
	}
	die "$createoverlap\n";
	return ($createoverlap) if ($createoverlap);
    } else {
	print "Not close $inc $id $percent\n";
    }
    return();
}

sub create_amb {
    $A="A";
    $C="C";
    $G="G";
    $T="T";
    $ambhash2{$A}{$C}="M";
    $ambhash2{$C}{$A}="M";
    $ambhash2{$A}{$G}="R";
    $ambhash2{$G}{$A}="R";
    $ambhash2{$A}{$T}="W";
    $ambhash2{$T}{$A}="W";
    $ambhash2{$C}{$G}="S";
    $ambhash2{$G}{$C}="S";
    $ambhash2{$C}{$T}="Y";
    $abmhash2{$T}{$C}="Y";
    $ambhash2{$G}{$T}="K";
    $ambhash2{$T}{$G}="K";
}

sub revcomp($){
    my(@pieces);
    my($j);
    my($seq);
    my($doit);
    ($doit)=($_);
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
