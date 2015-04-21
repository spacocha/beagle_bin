#! /usr/bin/perl -w

die "Usage: ref_tab 4bpfile no_barcodes length max_attempts > Redirect\n" unless (@ARGV);
($ref, $bp4file, $number, $length, $max) = (@ARGV);
chomp ($ref);
chomp ($bp4file);
chomp ($number);
chomp ($length);
chomp ($max);

die unless ($max);

$gocount=1;
#first make a string of ATGC the length of $length
open (IN, "<$ref") or die "Can't open $ref\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($refname, $refseq)=split ("\t", $line);
    $refhash{$refseq}=$refname;
}
close (IN);

push (@bases, "T");
push (@bases, "C");
push (@bases, "G");
push (@bases, "A");

open (IN, "<$bp4file") or die "Can't open $bp4file\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($time, $refname, $refseq)=split ("\t", $line);
    $done=();
    ($basem3, $basem2, $basem1)=$refseq=~/(.)(.)(.)$/;
    until ($done){
        $choose=int(rand(4));
        die "$choose is 4\n" if ($choose==4);
        $index=$choose;
        $randbase=$bases[$index];
        #does this randbase make a string of three of the same letters
	if ($basem1 && $basem2 && $basem3){
            if ($basem1 eq $basem2 && $basem2 eq $basem3 && $basem3 eq $randbase){
                #don't use this base
                next;
            }
        } else {
	    die "Missing minus bases $basem1, $basem2, $basem3\n";
	}
        #add this base to the existing string                                                                                                                                             
	$seq="$refseq"."$randbase";
	$done++;
    }
    $donehash{$seq}=$refname;
    $counthash{$seq}=$gocount;
    $gocount++;
    print "$time\t$refname\t$seq\n";
    ($namecount)=$refname=~/BAR(.+)$/;
}
close (IN);


$done2=();
until ($done2){
    $done=();
    $seq=();
    $basem1=();
    $basem2=();
    $basem3=();
    $baseadded=();
    until ($done){
	#pick a random number to make a random seq
	$choose=int(rand(4));
	die "$choose is 4\n" if ($choose==4);
	$index=$choose;
	$randbase=$bases[$index];
	#does this randbase make a string of three of the same letters
	if ($basem1 && $basem2 && $basem3){
	    if ($basem1 eq $basem2 && $basem2 eq $basem3 && $basem3 eq $randbase){
		#don't use this base
		next;
	    } 
	}
	#add this base to the existing string
	if ($seq){
	    $seq="$seq"."$randbase";
	    #print "$seq\n"
	} else {
	    $seq="$randbase";
	    #print "$seq\n";
	}
	$baseadded++;
	#don't have string of three of the same base
	#move all the bases over one
	$basem3=$basem2;
	$basem2=$basem1;
	$basem1=$randbase;
	if ($baseadded>=$length){
	    $done++;
	}
    }    
    $badbar="GAAGAGC";
    $hitsref=();
    foreach $refseq (sort keys %refhash){
	$hitsref++ if ($refseq=~/$seq/);
    }
    
    if ($donehash{$seq}){
	#print "Already has it: $seq\n";
	#don't keep a bar if it's already made
	$done2=();
    } elsif ($hitsref){
	#don't use if it matches any part of the ref seqs
	$done2=();
    } elsif ($badbar=~/$seq/ || $seq=~/$badbar/){
	#don't keep this code because it misprimes
	$done2=();
    }else {
	$removeit=();
	foreach $checkseq (keys %donehash){
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
	    if ($mismatch >=3){
		#it's ok if there are at least two mismatches
	    } else {
		$removeit++;
		last;
	    }
	    $j=$length-1;
	    #check frameshifting
	    ($f1seq)=$seq=~/^(.{$j}).$/;
	    ($f2seq)=$checkseq=~/^.(.{$j})$/;
	    ($f1check)=$seq=~/^(.{$j}).$/;
	    ($f2check)=$checkseq=~/^.(.{$j})$/;
	    die "Missing a mismatch\n" unless ($f1seq && $f2seq && $f1check && $f2check);
	    (@f1seqbp)=split ("", $f1seq);
	    (@f2checkbp)=split ("", $f2check);
	    (@f2seqbp)=split ("", $f2seq);
	    (@f1checkbp)=split ("", $f1check);
	    $i=0;
	    $j=$length-1;
	    $f1mis=0;
	    $f2mis=0;
	    until ($i>=$j){
		$f1mis++ unless ($f1seqbp[$i] eq $f2checkbp[$i]);
		$f2mis++ unless ($f2seqbp[$i] eq $f1checkbp[$i]);
		$i++;
	    }
	    if ($f1mis==0 || $f2mis==0){
		#don't keep a seqeunce if it's identical to another 1 frame shift
		$removeit++;
	    }
	    #don't allow any pair where a bp can be doubled or tripled and have the same sequence
	    #double and triple each base of the first and see if it matches the second
	    $j=$length-1;
	    $i=0;
	    $doublematch=0;
	    until ($i>=$j){
		#double the ith base to make 8 and see if it matches the checkseq
		$doubleseq=();
		$k=0;
		until ($k>=$j){
		    if ($doubleseq){
			$doubleseq="$doubleseq"."$f1seqbp[$k]";
		    } else {
			$doubleseq="$f1seqbp[$k]";
		    }
		    $doubleseq="$doubleseq"."$f1seqbp[$k]" if ($k==$i);
		    $k++;
		}
		if ($doubleseq eq $checkseq){
		    $doublematch++;
		}
		$i++;
	    }
	    #don't allow any base to be tripled and be identical to another barcode
            $j=$length-2;
            $i=0;
            $triplematch=0;
            until ($i>=$j){
                #double the ith base to make 8 and see if it matches the checkseq                                                                                         
                $tripleseq=();
                $k=0;
                until ($k>=$j){
                    if ($tripleseq){
                        $tripleseq="$tripleseq"."$f1seqbp[$k]";
                    } else {
                        $tripleseq="$f1seqbp[$k]";
                    }
                    $tripleseq="$tripleseq"."$f1seqbp[$k]"."$f1seqbp[$k]" if ($k==$i);
                    $k++;
                }
                if ($tripleseq eq $checkseq){
                    $triplematch++;
                }
                $i++;
            }
	    if ($triplematch>0){
		$removeit++;
	    }
	    #don't keep any sequences if when you remove one bp it is identical
	    (@seqbp)=split ("", $seq);
	    $j=$length;
	    $i=0;
	    $removematch=0;
	    until ($i>=$j){
		    #double the ith base to make 8 and see if it matches the checkseq
		$removeseq=();
		$k=0;
		until ($k>=$j){
		    if ($k==$i){
			$k++;
			next;
		    } else {
			if ($removeseq){
			    $removeseq="$removeseq"."$seqbp[$k]";
			} else {
			    $removeseq="$seqbp[$k]";
			}
		    }
		    $k++;
		}
		if ($checkseq=~/$removeseq/){
		    $removematch++;
		}
		$i++;
	    }
	    if ($removematch>0){
		$removeit++;
	    }

	}
	
	if ($removeit){
	    #return to make a new seqeunce
	    #print "Removed because of Similarity: $seq\n";
	    $failed++;
	    #die if you've made a million seqeunces that failed before adding a new one
	    if ($failed>$max){
		die "Failed: $failed Totalseq:$totalseq\n";
	    }
	    $done2=();
	} else {
	    $namecount++;
	    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
	    $newyear = $year+1900;
	    $newmonth=$mon+1;
	    $lt= "$newmonth-$mday-$newyear $hour:$min:$sec";
	    print "$lt\tBAR$namecount\t$seq\n";
	    $donehash{$seq}++;
	    $failed=();
	    $totalseq++;
	    if ($totalseq>$number){
		$done2++;
		#print "Finished\n";
	    } else {
		#print "Find another seqeunce\n";
		$done2=();
	    }
	}
    }
}

