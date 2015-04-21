#! /usr/bin/perl
#
#

	die "Usage: <Solexa File1> <Solexa File2> <mapping> <output_prefix>\n" unless (@ARGV);
	($file1, $file2, $input, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($file2);
chomp ($input);
chomp ($output);

open (IN, "<${input}") or die "Can't open $input\n";
$first=1;
while ($line=<IN>){
    next unless ($line);
    ($handle, $outname, $forname, $forseq, $fororient, $barname, $barseq, $barorient, $revname, $revseq, $revorient) = split ("\t", $line);
    #make a check of the forward barcode seq
    if ($first){
	$first=();
	next;
    } else {
	if ($fororient=~/[Ff]/){
	    $newforseq=$forseq;
	} else {
	    $rc_seq = $forseq;
	    ($newforseq)=revcomp();
	}	
	#check the barcode seq
	if ($barorient=~/[Ff]/){
	    $newbarseq=$barseq;
	} else {
	    $rc_seq=$barseq;
	    ($newbarseq)=revcomp();
	}
	#check the reverse bar seq
	if ($revorient=~/[Ff]/){
	    $newrevseq=$revseq;
	} else {
	    $rc_seq=$revseq;
	    ($newrevseq)=revcomp();
	}
	if ($handle eq "single"){
	    die "No N's in barcodes $newbarseq\n" if ($newbarseq=~/N/);
	    $singlehash{$newbarseq}=$outname;
	    print "NA\t$newbarseq\tNA\t$outname\n";
	} elsif ($handle eq "double"){
	    die "No N's in barcodes $newforseq $newrevseq\n" if ($newrevseq=~/N/ || $newrevseq=~/N/);
	    $doublehash{$newforseq}{$newrevseq}=$outname;
	    print "$newforseq\tNA\t$newrevseq\t$outname\n";
	} elsif ($handle eq "forbar"){
	    die "No N's in barcodes $newrevseq $newforseq\n" if ($newforseq=~/N/ || $newbarseq=~/N/);
	    $forbarhash{$newforseq}{$newbarseq}=$outname;
	    print "$newforseq\t$newbarseq\tNA\t$outname\n";
	}

	$oneoutname="$outname"."1";
	$twooutname="$outname"."2";
	#open the file handles to print to later
	unless ($opened{$oneoutname}){
	    open (${oneoutname}, ">${output}.${outname}.1") or die "Can't open ${output}.${outname}.1\n";
	    $opened{$oneoutname}++;
	}

	unless ($opened{$twooutname}){
	    open (${twooutname}, ">${output}.${outname}.2") or die "Can't open ${output}.${outname}.2\n";
	    $opened{$twooutname}++;
	}
    }
}
close (IN);

open (IN1, "<${file1}") or die "Can't open $file1\n";
open (IN2, "<${file2}") or die "Can't open $file2\n";
$first=1;
while ($header1=<IN1>){
    ($sequence1=<IN1>);
    ($useless1=<IN1>);
    ($qual1=<IN1>);
    ($header2=<IN2>);
    ($sequence2=<IN2>);
    ($useless2=<IN2>);
    ($qual2=<IN2>);
    chomp ($header1, $sequence1, $useless1, $qual1);
    chomp ($header2, $sequence2, $useless2, $qual2);
    ($bar1)=$header1=~/\#([A-z]+)\/[0-9]/;
    ($bar2)=$header2=~/\#([A-z]+)\/[0-9]/;
    die "Funky 1.) $bar1 $header1 2.) $bar2 $header2\n" unless ($bar1 eq $bar2);
    ($forward1)=$sequence1=~/^(.{5})/;
    ($reverse)=$sequence2=~/^(.{5})/;
    $printit=0;
    if ($singlehash{$bar1}){
	$printhand1="$singlehash{$bar1}"."1";
	$printhand2="$singlehash{$bar1}"."2";
	$printit++;
    } elsif ($doublehash{$forward1}{$reverse}){
	$printhand1="$doublehash{$forward1}{$reverse}"."1";
	$printhand2="$doublehash{$forward1}{$reverse}"."2";
	$printit++;
    } elsif ($forbarhash{$forward1}{$bar1}){
	$printhand1="$forbarhash{$forward1}{$bar1}"."1";
	$printhand2="$forbarhash{$forward1}{$bar1}"."2";
	$printit++;
    }
    if ($printit){
	print $printhand1 "${header1}\n$sequence1\n$useless1\n$qual1\n";
	print $printhand2 "${header2}\n$sequence2\n$useless2\n$qual2\n";
	
    }
}
close (IN1);
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
		die "What is this (reverse complement): $pieces[$j] $rc_seq\n";
	    }
	} else {
	    die "NO j $j\n";
	}
	$j--;
    }
    return ($seq);
}
