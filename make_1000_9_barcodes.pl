#! /usr/bin/perl -w

die "Usage: no_barcodes length > redirect\n" unless (@ARGV);
($number, $length) = (@ARGV);
chomp ($number);
chomp ($length);

die unless ($number && $length);

#first make a string of ATGC the length of $length

push (@bases, "A");
push (@bases, "T");
push (@bases, "C");
push (@bases, "G");

#die "Each $bases[0] $bases[1] $bases[2] $bases[3]\n";

#make a random sequence
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
	    if ($basem1 eq $basem2 && $basem2 eq $basem3 && $basem2 eq $randbase){
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
    #print "END done $seq\n";

    if ($donehash{$seq}){
	#print "Already has it: $seq\n";
	#don't keep a bar if it's already made
	$done2=();
    } else {
	#print "Checking for mismatches: $seq\n";
	$removeit=();
	foreach $checkseq (keys %donehash){
	    #don't check itself
	    next if ($checkseq eq $seq);
	    #check to see if it's 3 bp from another sequence
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
		#it's ok
	    } else {
		$removeit++;
		last;
	    }
	    
	    ($f1seq)=$seq=~/^(.{8}).$/;
	    ($f2seq)=$checkseq=~/^.(.{8})$/;
	    ($f1check)=$seq=~/^(.{8}).$/;
	    ($f2check)=$checkseq=~/^.(.{8})$/;
	    die "Missing\n" unless ($f1seq && $f2seq && $f1check && $f2check);
	    (@f1seqbp)=split ("", $f1seq);
	    (@f2checkbp)=split ("", $f2check);
	    (@f2seqbp)=split ("", $f2seq);
	    (@f1checkbp)=split ("", $f1check);
	    $i=0;
	    $j=7;
	    $f1mis=0;
	    $f2mis=0;
	    until ($i>=$j){
		$f1mis++ unless ($f1seqbp[$i] eq $f2checkbp[$i]);
		$f2mis++ unless ($f2seqbp[$i] eq $f1checkbp[$i]);
		$i++;
	    }
	    if ($f1mis<=1 || $f2mis<=1){
		#don't keep a seqeunce if it's identical to 7 bp with 1 frame shift
		$removeit++;
	    }
	    #don't allow any pair where a bp can be doubled and have the same sequence
	    #double each base of the first and see if it matches the second
	    $j=8;
	    $i=0;
	    $doublematch=0;
	    until ($i>=$j){
		#double the ith base to make 8 and see if it matches the checkseq
		$doubleseq=();
		$k=0;
		until ($k>=8){
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
	    die "Too many failure. This is my number $totalseq\n" if ($failed>1000000);
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

