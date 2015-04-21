#! /usr/bin/perl -w

die "Usage: ref_tab no_barcodes length max_attempts goal output_file\n" unless (@ARGV);
($ref, $number, $length, $max, $goal, $file) = (@ARGV);
chomp ($ref);
chomp ($number);
chomp ($length);
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
open (OUT, ">$file") or die "Can't open $file\n";
$attempts=0;
#make a random sequence
until ($done3){
    until ($done2){
	$done=();
	$seq=();
	$basem1=();
	$basem2=();
	$baseadded=();
	until ($done){
	    #pick a random number to make a random seq
	    $choose=int(rand(4));
	    die "$choose is 4\n" if ($choose==4);
	    $index=$choose;
	    $randbase=$bases[$index];
	    #does this randbase make a string of three of the same letters
	    if ($basem1 && $basem2){
		if ($basem1 eq $basem2 && $basem2 eq $randbase){
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
		if ($mismatch >=2){
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
		die "Missing\n" unless ($f1seq && $f2seq && $f1check && $f2check);
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
		
		if ($doublematch>0 || $removematch>0){
		    $removeit++;
		}
	    }
	    
	    if ($removeit){
		#return to make a new seqeunce
		#print "Removed because of Similarity: $seq\n";
		$failed++;
		#die if you've made a million seqeunces that failed before adding a new one
		if ($failed>$max){
		    if ($totalseq>=$goal){
			die "Goal attained. This is my number $totalseq $attempts\n";
			$done3++;
		    } else {
			$attempts++;
			$totalseq=0;
			$namecount=0;
			close (OUT);
			if (-e $file){
			    system ("rm $file");
			} else {
			    die "Can't find $file\n";
			}
			open (OUT, ">${file}") or die "Can't open $file\n";
			%donehash=();
			$done2=();
			$done3=();
		    }
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
}
