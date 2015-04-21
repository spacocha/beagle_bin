#! /usr/bin/perl
#
#

die "<file> > redirect\n" unless (@ARGV);
($file)=(@ARGV);
chomp ($file);

open (IN1, "<$file") or die "Can't open $file\n";
while ($line=<IN1>){
    chomp ($line);
    next unless ($line);
    ($lib, $rc_seq) = split ("\t", $line);
    $rc_seq=~s/ //g;#remove spaces
    ($bar_rc) = revcomp();
    $rc_seq = $bar_rc;
    print "$lib\t$rc_seq\n";
}
close (IN1);

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
		die "RC NO Piece: $pieces[$j]\n";
	    }
	} else {
	    die "NO j $j\n";
	}
	$j--;
    }
    return ($seq);
}
