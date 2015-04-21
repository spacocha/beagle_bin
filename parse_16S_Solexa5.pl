#! /usr/bin/perl
#
#

	die "Usage: <Solexa File1> <Solexa file2> <True barcodes> <output name>\n" unless (@ARGV);
	($file1, $file2, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($file2);
chomp ($output);

$/="@";
$count=1;
$lnum=1;
#open the forward file and save for later
open (IN2, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN2>){
		chomp ($line);
		next unless ($line);
		($header, $sequence, $useless1, $useless2)=split("\n", $line);
		($shrt_head) = $header =~/^(.+\#.*.{7})\/1$/;
		$hash1{$shrt_head}=$sequence;
	    }
	close (IN2);

#open the reverse read and print as fasta
open (OUT, ">${output}") or die "Can't eopn ${output}\n";
open (IN3, "<$file2") or die "Can't open $file2\n";
while ($line=<IN3>){
    chomp ($line);
    next unless ($line);
    ($header, $sequence, $useless1, $useless2)=split("\n", $line);
    ($shrt_head) = $header =~/^(.+\#.*.{7})\/2$/;
    if ($hash1{$shrt_head}){
        ($rc_seq) = $sequence=~/^([A-z]{92})/;
        ($seq2_rc) = revcomp();
        $total16S = "$hash1{$shrt_head}"."$seq2_rc";
        print OUT ">$shrt_head\n$total16S\n\n";
    }
}
close (IN3);
close (OUT);

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
