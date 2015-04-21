#! /usr/bin/perl
#
#

	die "Usage: names\n" unless (@ARGV);
	($file1, $file2, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($file2);
chomp ($output);

$/="@";

open (IN1, "<$file1") or die "Can't open $file1\n";
open (IN2, "<${file2}") or die "Can't open $file2\n";
$first=1;
while ($line1=<IN1>){
    ($line2=<IN2>);
    if ($first){
	$first=();
    } else {
	chomp ($line1);
	chomp ($line2);
	next unless ($line1 && $line2);
	($header1, $sequence1, $useless1, $qual1)=split("\n", $line1);
	($header2, $sequence2, $useless2, $qual2)=split("\n", $line2);
	($bar1)=$header1=~/\#([A-z]{8})\/[0-9]/;
	($bar2)=$header2=~/\#([A-z]{8})\/[0-9]/;
	die "Funky $bar1 $header1 $bar2 $header2\n" unless ($bar1 eq $bar2);
	($forward1)=$sequence1=~/^(.{5})/;
	($reverse)=$sequence2=~/^(.{5})/;
	if ($forward1 eq "GCAGG" && $reverse eq "ACTGA"){
	    $totalfGCAGG++;
	    $totalrACTGA++;
	    $barhash{$bar1}++;
	}
    }
}
close (IN1);
close (IN2);

print "Total for A4 B8:
foreard GCAGG $totalfGCAGG
reverse ACTGA $totalrACTGA\n";

foreach $bar (sort {$barhash{$b} <=> $barhash{$a}} keys %barhash){
    print "$bar\t$barhash{$bar}\n";
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
