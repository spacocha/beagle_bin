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

open (IN, "<$bp4file") or die "Can't open $bp4file\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($time, $refname, $refseq)=split ("\t", $line);
    $bp4hash{$refseq}=$refname;
    $counthash{$refseq}=$gocount;
    $gocount++;
}
close (IN);


push (@bases, "T");
push (@bases, "C");
push (@bases, "G");
push (@bases, "A");
$three=3;
$two=2;
#add one base to the existing 4 bp set
foreach $bp4bar (sort {$counthash{$a} <=> $counthash{$b}} keys %counthash){
    $done2=();
    until ($done2){
	$seq=$bp4bar;
	(@tempbases)=split ("", $seq);
	$basem1=$tempbases[$three];
	$basem2=$tempbases[$two];
	$done=();
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
		    $done=();
		} else { 
		    $seq="$seq"."$randbase";
		    $done++;
		}
	    } else {
		die "Missing $basem1 and $basem2\n";
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
	} else {
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
		die "Missing $seq $checkseq\n" unless ($f1seq && $f2seq && $f1check && $f2check);
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
		
		if ($doublematch>0){
		    $removeit++;
		}
	    }
	    
	    if ($removeit){
		#return to make a new seqeunce
		#print "Removed because of Similarity: $seq\n";
		$failed++;
		#die if you've made a million seqeunces that failed before adding a new one
		if ($failed>$max){
		    die "Max attempts. This is my number $totalseq\n";
		    $done2++;
		} else {
		    $done2=();
		}
	    } else {
		$namecount++;
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
		$newyear = $year+1900;
		$newmonth=$mon+1;
		$lt= "$newmonth-$mday-$newyear $hour:$min:$sec";
		print "$lt\t$bp4hash{$bp4bar}\t$seq\n";
		$donehash{$seq}++;
		$failed=();
		$totalseq++;
		$done2++;
	    }
	}
    }
}
