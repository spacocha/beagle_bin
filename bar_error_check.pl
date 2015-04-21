#! /usr/bin/perl -w

die "Usage: ref_tab >redirect\n" unless (@ARGV);
($ref) = (@ARGV);
chomp ($ref);

#first make a string of ATGC the length of $length
open (IN, "<$ref") or die "Can't open $ref\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/otal/);

    ($barcode, $count, $freq, $freq2, $ver)=split ("\t", $line);

    if ($ver=~/True/){
	$oldhash{$barcode}=$count;
    } else {
	$falsehash{$barcode}=$count;
    }
}
close (IN);
$allowmis=1;
$length=7;
#make a random sequence out of the old barcodes
foreach $seq (sort keys %falsehash){
    foreach $checkseq (sort keys %oldhash){
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
#	print "Mismatches: $mismatch $seq $checkseq\n";
	if ($mismatch >=$allowmis){
	    #it's ok if there are at least two mismatches
	} else {
	    print "Fewer than allowed mis: $seq $checkseq\n";
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
	    print "Frameshift: $seq $checkseq\n";
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
		print "Doublematch: $seq $checkseq\n";
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
		print "Triplematch: $seq $checkseq\n";
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
		print "Removematch: $seq $checkseq\n";
	    }
	    $i++;
	}
	
    }
}

