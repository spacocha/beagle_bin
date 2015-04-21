#! /usr/bin/perl
#
# Use this file to get all the sequences for which both f and r useable seqs are longer then median length

	die "Usage: <file>\n" unless (@ARGV);
	($list) = (@ARGV);

	die "Please follow command line args\n" unless ($list);
chomp ($list);


open (IN1, "<$list") or die "Can't open $list\n";
while ($line2=<IN1>){
	chomp ($line2);
	next unless ($line2);
	($header, $lib, $fseq, $qual, $rseq, $rqual)=split("\t", $line2);
	#what is the length of forward and reverse read
	$flength = split ("", $fseq);
	$rlength = split ("", $rseq);

	#store sequence in a hash
	$libhash{$header}=$lib;
	$fseqhash{$header}=$fseq;
	$qualhash{$header}=$qual;
	$rseqhash{$header}=$rseq;
	$rqualhash{$header}=$rqual;
	#store the length to get median
	push (@farray, $flength);
	push (@rarray, $rlength);
    }
close (IN1);

#total number of sequences
$flen = @farray;
$rlen = @rarray;

#sort the array from short to long
(@nfarray) = sort {$a <=> $b}  (@farray);
(@nrarray) = sort {$a <=> $b} (@rarray);

#get the middle and total index
$halfflen = int($flen/2);
$halfrlen = int($rlen/2);

$halfflen1 = $halfflen-1;
$halfrlen1 = $halfrlen-1;
$flen1 = $flen-1;
$rlen1 = $rlen-1;

#use middle index to get media forward and reverse lengths
$fmed = $nfarray[$halfflen1];
$rmed = $nrarray[$halfrlen1];
if ($fmed > 92){
    #don't make the sequences longer than 92 bp because of the mothur alignment
    $fmed = 92;
}
if ($rmed > 80){
    #don't make the sequences longer than 80 bp because of the mothur alignment
    $rmed = 80;
}

#make complete sequence for rdp
$letter = "N";
$length = 217 + 172 - $fmed - $rmed;
$Ns = $letter x $length;

foreach $name (keys %fseqhash){
    $forward=split ("", $fseqhash{$name});
    $reverse= split ("", $rseqhash{$name});
    #if both sequence are at least the median length
    if ($forward >=$fmed && $reverse >= $rmed){
	($fgrab) = $fseqhash{$name}=~/^(.{$fmed})/;
	($rgrab) = $rseqhash{$name}=~/(.{$rmed})$/;
	($qualgrab)= $qualhash{$name}=~/^(.{$fmed})/;
	($rqualgrab)=$rqualhash{$name}=~/(.{$rmed})$/;
	print "$name\t$libhash{$name}\t$fgrab\t$qualgrab\t$rgrab\t$rqualgrab\n";
    }
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
