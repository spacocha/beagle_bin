#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Use this program on QIIME formatted data
Usage: <forward> <reverse read to be reverse complemented> > Redirect output\n" unless (@ARGV);
	
chomp (@ARGV);
($ffile, $rfile) = (@ARGV);
$/ = ">";
open (IN, "<$ffile") or die "Can't open $ffile\n";
while ($line1 = <IN>){	
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    ($libno, $unique, $rest)=$info=~/^(.+_[0-9]+) (.+)\/[0-9]+ (.+)$/;
    ($sequence) = join ("", @pieces);
    $sequence =~tr/\n//d;
    $seqhash{$unique}=$sequence;
    $infohash{$unique}=$info;
}

close (IN);
open (IN, "<$rfile") or die "Can't open $rfile\n";
while ($line1 = <IN>){
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    ($libno, $unique, $rest)=$info=~/^(.+_[0-9]+) (.+)\/[0-9]+ (.+)$/;
    ($rc_seq) = join ("", @pieces);
    $rc_seq =~tr/\n//d;
    ($newseq)=revcomp();
    if ($seqhash{$unique} && $infohash{$unique}){
	(@fbases)=split ("", $seqhash{$unique});
	(@rbases)=split ("", $newseq);
	$flen=@fbases;
	$rlen=@rbases;
	$ftotal{$flen}++;
	$rtotal{$rlen}++;
#	print ">$infohash{$unique}\n${seqhash{$unique}}${newseq}\n";
	$total++;
    }
}
close (IN);

foreach $len (sort keys %ftotal){
    print "$len\t$ftotal{$len}\n";
}
foreach $len (sort keys %rtotal){
    print "$len\t$rtotal{$len}\n";
}
die "$total\n";


############
#subroutines of very common use
############

sub revcomp{
    (@pieces) = split ("", $rc_seq);
    #make reverse complement
    $j = @pieces;
    $j-=1;
    $seq = ();
    until ($j < 0){
	if ($pieces[$j]){
	    if ($pieces[$j] eq "A"){
		if ($seq){
		    $seq = "$seq"."T";
		} else {
		    $seq="T";
		}
	    } elsif ($pieces[$j] eq "T"){
		if ($seq){
		    $seq = "$seq"."A";
		} else {
		    $seq="A";
	    } elsif ($pieces[$j] eq "C"){
		if ($seq){
		    $seq = "$seq"."G";
		} else {
		    $seq="G";
		}
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

1;
