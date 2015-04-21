#! /usr/bin/perl -w

die "Usage: tab seqcol > redirect\n" unless (@ARGV);
($tab) = (@ARGV);
chomp ($tab);

open (IN, "<$tab" ) or die "Can't open $tab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($time, $name, $seq)=split ("\t", $line);
    $hash{$name}=$seq;
    $timehash{$name}=$time;
} 
close (IN);

foreach $name (sort keys %hash){
    foreach $othername (sort keys %hash){
	next if ($name eq $othername);
	#check if this pair has already been done
	next if ($removehash{$name}{$othername} || $removehash{$othername}{$name});
	#don't allow any that are identical in one frame shift
	($f1seq)=$hash{$name}=~/^(.{7}).$/;
	($f2seq)=$hash{$name}=~/^.(.{7})$/;
	($f1check)=$hash{$othername}=~/^(.{7}).$/;
	($f2check)=$hash{$othername}=~/^.(.{7})$/;
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
	if ($f1mis==0 || $f2mis==0){
	    $removehash{$name}{$othername}++;
	    $removecount{$name}++;
	    $removecount{$othername}++;
	}
	#don't allow any pair where a bp can be doubled and have the same sequence
	#double each base of the first and see if it matches the second
	$j=7;
	$i=0;
	$doublematch=0;
	until ($i>=$j){
	    #double the ith base to make 8 and see if it matches the checkseq
	    $doubleseq=();
	    $k=0;
	    until ($k>=7){
		if ($doubleseq){
		    $doubleseq="$doubleseq"."$f1seqbp[$k]";
		} else {
		    $doubleseq="$f1seqbp[$k]";
		}
		$doubleseq="$doubleseq"."$f1seqbp[$k]" if ($k==$i);
		$k++;
	    }
	    if ($doubleseq eq $hash{$othername}){
		$doublematch++;
	    }
	    $i++;
	}
	if ($doublematch>0){
	    $removehash{$name}{$othername}++;
	    $removecount{$name}++;
	    $removecount{$othername}++;
	}
    }
}

foreach $name (sort {$removecount{$b} <=> $removecount{$a}} keys %removecount){
    #only remove this name if I didn't already remove all the other guys that make this pair
    $otheroccur=0;
    foreach $othername (sort keys %{$removehash{$name}}){
	$otheroccur++ unless ($removed{$othername});
    }
    if ($otheroccur){
	#haven't already removed the other guys that match it, so remove it
	$removed{$name}++;
    }
}

foreach $name (sort keys %hash){
    print "$timehash{$name}\t$name\t$hash{$name}\n" unless ($removed{$name});
}
