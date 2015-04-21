#! /usr/bin/perl -w

die "Usage: ref_tab no_barcodes length_barcode mismatches_allowed max_failed max_iter goal output_file\n" unless (@ARGV);
($ref, $number, $length, $allowmis, $max, $iter, $goal, $file) = (@ARGV);
chomp ($ref);
chomp ($number);
chomp ($length);
chomp ($allowmis);
chomp ($max);

die unless ($number && $length && $ref);

#first make a string of ATGC the length of $length
open (IN, "<$ref") or die "Can't open $ref\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($refname, $refseq)=split ("\t", $line);
    $refhash{$refseq}=$refname;
}
close (IN);

push (@bases, "A");
push (@bases, "T");
push (@bases, "C");
push (@bases, "G");

#die "Each $bases[0] $bases[1] $bases[2] $bases[3]\n";
$attempts=0;
#make a random sequence
until ($done3){
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
		if ($mismatch >=$allowmis){
		    #it's ok if there are at least two mismatches
		} else {
		    $removeit++;
		}
		$j=$length-1;
		#check frameshifting
		($f1seq)=$seq=~/^(.{$j}).$/;
		($f1check)=$checkseq=~/^(.{$j}).$/;
		($f2seq)=$seq=~/^.(.{$j})$/;
		($f2check)=$checkseq=~/^.(.{$j})$/;
		(@f1seqbp)=split ("", $f1seq);
		(@f1checkbp)=split ("", $f1check);
		die "Missing\n" unless ($f1seq && $f2seq && $f1check && $f2check);
		if ($f1seq=~/$f2check/ || $f2seq=~/$f1check/){
		    #don't keep a seqeunce if it's identical to another 1 frame shift
		    $removeit++;
		}
		#don't allow any pair where a bp can be doubled or tripled and have the same sequence
		#double and triple each base of the first and see if it matches the second
		#double in seq
		$j=$length-1;
		$i=0;
		$doublematch=0;
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
		    if ($doubleseq=~/$checkseq/ || $doublecheck=~/$seq/ || $checkseq=~/$doublematch/ || $seq=~/$doublecheck/){
			$doublematch++;
		    }
		    $i++;
		}
                #don't allow any pair where a bp can be doubled or tripled and have the same sequence
#double and triple each base of the first and see if it matches the second                                                                                                             
                $j=$length-2;
                $i=0;
                $triplematch=0;

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
                    if ($checkseq=~/$tripleseq/ || $tripleseq=~/$checkseq/ || $triplecheck=~/$seq/ ||$seq=~/$triplecheck/){
                        $triplematch++;
                    }
                    $i++;
                }
		#don't keep any sequences if when you remove one bp it is identical
		(@seqbp)=split ("", $seq);
		(@checkbp)=split ("", $checkseq);
		$j=$length;
		$i=0;
		$removematch=0;
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
		    if ($checkseq=~/$removeseq/ || $removeseq=~/$checkseq/ || $removecheck=~/$seq/ || $seq=~/$removecheck/){
			$removematch++;
		    }
		    $i++;
		}
		
		if ($doublematch>0 || $removematch>0 ||$triplematch>0){
		    $removeit++;
		}
	    }
	    
	    if ($removeit){
		#return to make a new seqeunce
		#print "Removed because of Similarity: $seq\n";
		$failed++;
		#die if you've made a million seqeunces that failed before adding a new one
		if ($failed>$max){
		    #if you have reach the max number of attempts, reset everything
		    if ($totalseq>=$number){
			#if you reached the goal, print the hash
			foreach $name (sort keys %printhash){
			    print "$printhash{$name}\n";
			}
			#get out of the loops
			$done++;
			$done2++;
			$done3++;
			last;
		    } else {
			#if your goal is not met, print the largest hash
			$attempts++;
			if ($attempts>$iter){
			    #print out the max hash
			    if ($totalseq > $printhashmax){
				foreach $name (sort keys %printhash){
				    print "$printhash{$name}\n";
				}
			    } else {
				foreach $name (sort keys %maxprinthash){
				    print "$maxprinthash{$name}\n";
				}
			    }
			    #get out of the loops
			    $done++;
			    $done2++;
			    $done3++;
			    last;
			} else {
			    #store the larger of printhash and maxprinthash
			    if ($totalseq > $printhashmax){
				#this is a new largest value
				%maxprinthash=%printhash;
				$printhashmax=$totalseq;
				%printhash=();
			    } else {
				%printhash=();
			    }
			    #reset values
			    $totalseq=0;
			    $namecount=0;
			    %donehash=();
			    #stay in loops
			    $done=();
			    $done2=();
			    $done3=();
			}
		    }
		}
		$done=();
		$done2=();
		$done3=();
	    } else {
		$namecount++;
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
		$newyear = $year+1900;
		$newmonth=$mon+1;
		$lt= "$newmonth-$mday-$newyear $hour:$min:$sec";
		$string="$lt\tBAR$namecount\t$seq";
		$name="BAR"."$namecount";
		$printhash{$namecount}=$string;
		$donehash{$seq}++;
		$failed=();
		$totalseq++;
		if ($totalseq>$number){
		    $done2++;
		    foreach $name (sort keys %printhash){
			print "$printhash{$name}\n";
		    }
		    $done3++;
		    $done++;
		    last;
		} else {
		    #print "Find another seqeunce\n";
		    $done2=();
		}
	    }
	}
    }
}
