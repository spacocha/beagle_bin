#! /usr/bin/perl -w

die "Usage: ref_tab in_file length allowed_mismatches last_barno> Redirect\n" unless (@ARGV);
($ref, $bp4file, $length, $allowmis, $last) = (@ARGV);
chomp ($ref);
chomp ($bp4file);
chomp ($length);
chomp ($allowmis);
chomp ($last);

die "please follow command line options\n" unless ($last);

$gocount=1;
#first make a string of ATGC the length of $length
print "Reading ref\n";
open (IN, "<$ref") or die "Can't open $ref\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($refname, $refseq)=split ("\t", $line);
    $refhash{$refseq}=$refname;
}
close (IN);
print "Reading bars\n";
open (IN, "<$bp4file") or die "Can't open $bp4file\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($refname, $refseq)=split ("\t", $line);
    if ($refname=~/BAR/){
	($barno)=$refname=~/BAR(.+)$/;
	if ($barno>$last){
        #go to the next line                                                                                                                                                    
	    next;
	}
    } else {
	$barno=$refname;
    }
    ($shrtlen)=$refseq=~/^(.{$length})/;
    if ($donehash{$shrtlen}){
	print "Same seq: |$refname| |$donehash{$shrtlen}| |$shrtlen| |$refseq|\n";
    } else {
	$donehash{$shrtlen}=$refname;
	$counthash{$shrtlen}=$gocount;
	$gocount++;
    }   
}
close (IN);


push (@bases, "T");
push (@bases, "C");
push (@bases, "G");
push (@bases, "A");
#add one base to the existing 5 bp set
foreach $seq (sort {$counthash{$a} <=> $counthash{$b}} keys %counthash){
    $badbar="GAAGAGC";
    $hitsref=();
    foreach $refseq (sort keys %refhash){
	$hitsref++ if ($refseq=~/$seq/);
    }
    
    if ($hitsref){
	#don't use if it matches any part of the ref seqs
	print "Hits ref: $seq $donehash{$seq}\n";
    } elsif ($badbar=~/$seq/ || $seq=~/$badbar/){
	#don't keep this code because it misprimes
	print "Bad bar:$seq $donehash{$seq}\n";
    } else {
	foreach $checkseq (keys %donehash){
	    next if ($seq eq $checkseq);
	    #don't check itself
	    #check to see if it's some number of bp from another sequence
	    #print "Checking for mismatches: $seq $checkseq\n";
	    (@basesnew)=split ("", $seq);
	    (@basescheck)=split ("", $checkseq);
	    $j=@basesnew;
	    $i=0;
	    $mismatch=0;
	    until ($i >=$j){
		$mismatch++ unless ($basescheck[$i] eq $basesnew[$i]);
		$i++;
	    }
	    #print "Mismatches: $mismatch $seq $checkseq\n";
	    if ($mismatch >=$allowmis){
		#it's ok if there are at least two mismatches
	    } else {
		print "Fewer than $allowmis mismatches: $seq $checkseq $donehash{$seq} $donehash{$checkseq}\n";
	    }
	    $j=$length-1;
	    #check frameshifting
	    ($f1seq)=$seq=~/^(.{$j}).$/;
	    ($f1check)=$checkseq=~/^(.{$j}).$/;
	    ($f2seq)=$seq=~/^.(.{$j})$/;
	    ($f2check)=$checkseq=~/^.(.{$j})$/;
	    die "Missing $seq $checkseq\n" unless ($f1seq && $f2seq && $f1check && $f2check);
	    $i=0;
	    $j=$length-1;
	    if ($f1seq=~/$f2check/ || $f2seq=~/$f1check/ || $f2check=~/$f1seq/ || $f1check=~/$f2seq/){
		#don't keep a seqeunce if it's identical to another 1 frame shift
		print "Exact match in frame shift: $seq $donehash{$seq} $checkseq $donehash{$checkseq}\n";
	    }
	    #don't allow any pair where a bp can be doubled or tripled and have the same sequence
	    #double and triple each base of the first and see if it matches the second
	    (@f1seqbp)=split ("", $f1seq);
	    (@f1checkbp)=split ("", $f1check);
	    $j=$length-1;
	    $i=0;
	    until ($i>=$j){
		#double the ith base to make 8 and see if it matches the checkseq
		$doubleseq=();
		$doublecheck=();
		$k=0;
		until ($k>=$j){
		    if ($doubleseq){
			$doubleseq="$doubleseq"."$f1seqbp[$k]";
			$doublecheck="$doublecheck"."$f1checkbp[$k]";
		    } else {
			$doubleseq="$f1seqbp[$k]";
			$doublecheck="$f1checkbp[$k]";
		    }
		    $doubleseq="$doubleseq"."$f1seqbp[$k]" if ($k==$i);
		    $doublecheck="$doublecheck"."$f1checkbp[$k]" if ($k==$i);
		    $k++;
		}
		if ($doubleseq=~/$checkseq/ || $doublecheck=~/$seq/ || $checkseq=~/$doubleseq/ || $seq=~/$doublecheck/){
		    print "Doublematch: $seq $donehash{$seq} $checkseq $donehash{$checkseq}\n";
		}
		$i++;
	    }
            $j=$length-2;
            $i=0;
            until ($i>=$j){
                #double the ith base to make 8 and see if it matches the checkseq                                                                                                               
                $tripleseq=();
		$triplecheck=();
                $k=0;
                until ($k>=$j){
                    if ($tripleseq){
                        $tripleseq="$tripleseq"."$f1seqbp[$k]";
			$triplecheck="$triplecheck"."$f1checkbp[$k]";
                    } else {
                        $tripleseq="$f1seqbp[$k]";
			$triplecheck="$f1checkbp[$k]";
                    }
                    $tripleseq="$tripleseq"."$f1seqbp[$k]"."$f1seqbp[$k]" if ($k==$i);
		    $triplecheck="$triplecheck"."$f1checkbp[$k]"."$f1checkbp[$k]" if ($k==$i);
                    $k++;
                }
                if ($tripleseq=~/$checkseq/ || $triplecheck=~/$seq/ || $checkseq=~/$tripleseq/ || $seq=~/$triplecheck/){
                    print "Triplematch: $seq $donehash{$seq} $checkseq $donehash{$checkseq}\n";
                }
                $i++;
            }
	    #don't allow if a base is removed
	    (@seqbp)=split ("", $seq);
	    (@checkbp)=split ("", $checkseq);
	    $j=$length;
	    $i=0;
	    until ($i>=$j){
		#double the ith base to make 8 and see if it matches the checkseq
		$removeseq=();
		$removecheck=();
		$k=0;
		until ($k>=$j){
		    if ($k==$i){
			$k++;
			next;
		    } else {
			if ($removeseq){
			    $removeseq="$removeseq"."$seqbp[$k]";
			    $removecheck="$removecheck"."$checkbp[$k]";
			} else {
			    $removeseq="$seqbp[$k]";
			    $removecheck="$checkbp[$k]";
			}
		    }
		    $k++;
		}
		if ($checkseq=~/$removeseq/ || $removecheck=~/$seq/ || $removeseq=~/$checkseq/ || $seq=~/$removecheck/){
		    print "Remove match: SEQ:$seq $donehash{$seq} Checkseq:$checkseq $donehash{$checkseq}\n";
		}
		$i++;
	    }
	}
    }
}

sub revcomp{
    my(@pieces);
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
		die "RC NO Piece: $pieces[$j]\n";
	    }
	} else {
	    die "NO j $j\n";
	}
	$j--;
    }
    return ($seq);
}
