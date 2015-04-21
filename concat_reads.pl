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

open (IN1, "<$file2") or die "Can't open $file2\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($header1, @seqs)=split("\n", $line1);
    ($sequence)=join ("", @seqs);
    ($matching)=$header1=~/^.+_[0-9]+ (.+)\/[1-2] /;
    if ($hash1{$matching}){
	#print "$matching\n";
	#theres a matching one in the other file, join them
	#first, see whether one completely overlaps the other
	$sequence1=$hash1{$matching};
	if ($sequence1=~/$sequence/){
	    print "It's a straight match\n";
	    print ">$header1\n$sequence1\n";
	} elsif ($sequence=~/$sequence1/){
	    print "It's a straight match\n";
	    print ">$header1\n$sequence\n";
	} else{
	    $sendit[0]=$sequence1;
	    $sendit[1]=$sequence;
	    $concatseq=();
	    print "Trying forward\n";
	    ($concatseq)=find_overlap(@sendit);
	    unless ($concatseq){
		@sendit=();
		$sendit[0]=$sequence;
		$sendit[1]=$sequence1;
		print "Trying reverse\n";
		($concatseq)=find_overlap(@sendit);
	    }
	    if ($concatseq){
		if ($concatseq=~/[A-z]/){
		    print ">$header1\n${concatseq}\n";
		} else {
		    die "Read is funky $header1 $concatseq\n";
		}
	    }
	}
    }
}
close (IN1);

sub find_overlap{
    my (@pieces1);
    my (@peices2);
    my ($i);
    my ($j);
    my ($k);
    my ($useit);
    my ($overlap1, $overlap2, $beginning, $end);
    my (@seqs);
    my ($string);
    $string=();
    (@seqs)=(@_);
    print "Passed @seqs\n";
    $i=5;
    (@pieces1)=split ("", $seqs[0]);
    (@pieces2)=split ("", $seqs[1]);
    $j=@pieces1;
    $k=@pieces2;
    if ($j > $k){
	$useit=$j;
    } else {
	$useit=$k;
    }
    until ($useit <= $i){
	($overlap1)=$seqs[0]=~/^(.{$useit})/;
	($overlap2)=$seqs[1]=~/(.{$useit})$/;
	if ($overlap1 eq $overlap2){
	    ($beginning)=$seqs[1]=~/^(.*).{$useit}$/;
	    ($end)=$seqs[0]=~/^.{$useit}(.*)$/;
	    print "$beginning $overlap1 $end\n";
	    ($string)="${beginning}${overlap1}${end}";
	    return ($string);
	    last;
	}
	$useit--;
    }
    die "Never found overlap\n";
}


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
		die "$pieces[$j]\n";
	    }
	} else {
	    die "NO j $j\n";
	}
	$j--;
    }
    return ($seq);
}
