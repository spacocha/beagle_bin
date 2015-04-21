#! /usr/bin/perl -w

die "Usage: reftab bartab > redirect\n" unless (@ARGV);
($reftab, $bartab) = (@ARGV);
chomp ($reftab);
chomp ($bartab);

open (IN, "<$reftab" ) or die "Can't open $reftab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $seq)=split ("\t", $line);
    $refhash{$name}=$seq;
} 
close (IN);

open (IN, "<$bartab" ) or die "Can't open $bartab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($time, $barname, $barseq)=split ("\t", $line);
    foreach $name (keys %refhash){
	if ($refhash{$name}=~/$barseq/){
	    #don't use this sequence
	    print "Found a match: $name $refhash{$name} $barseq $barname\n";
	}
	$rc_seq=$barseq;
	($rev)=revcomp();
	if ($refhash{$name}=~/$rev/){
	    #don't use this sequence
            print "Found a match: $name $refhash{$name} $rev RC $barname\n";
	}
    }
}
close (IN);

sub revcomp{
    my (@pieces);
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
