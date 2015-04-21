#! /usr/bin/perl
#
#

	die "Usage: <for_primers> <rev_primers> <fasta> > redirect\n" unless (@ARGV);
	($fprimers, $rprimers, $file1) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
chomp ($fprimers);
chomp ($rprimers);

$/=">";

open (IN1, "<$fprimers") or die "Can't open $fprimers\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($header1, @seqs)=split("\n", $line1);
    ($sequence)=join ("", @seqs);
    $fprimerhash{$header1}=$sequence;
}
close (IN1);

open (IN1, "<$rprimers") or die "Can't open $rprimers\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($header1, @seqs)=split("\n", $line1);
    ($sequence)=join ("", @seqs);
    ($rev_comp_seq)=revcomp ($sequence);
    die "messed up rc\n" unless ($rev_comp_seq);
    $rprimerhash{$header1}=${rev_comp_seq};
}
close (IN1);

open (IN1, "<$file1") or die "Can't open $file1\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($header1, @seqs)=split("\n", $line1);
    ($sequence)=join ("", @seqs);
    $fprimerfound=0;
    foreach $fprimer (sort keys %fprimerhash){
	if ($fprimerhash{$fprimer}){
	    if ($sequence=~/$fprimerhash{$fprimer}/){
		($keep)=$sequence=~/${fprimerhash{$fprimer}}(.+)$/;
		die "Already found match $header1 $sequence $primer $fprimerhash{$fprimer}\n" if ($fprimerfound);
		$fprimerfound++;
		$rprimerfound=0;
		foreach $rprimer (sort keys %rprimerhash){
		    if ($rprimerhash{$rprimer}){
			if ($sequence=~/$rprimerhash{$rprimer}/){
			    ($longkeep)=$keep=~/^(.+)${rprimerhash{$rprimer}}/;
			    die "Already found match $header1 $sequence $primer $rprimerhash{$rprimer}\n" if ($rprimerfound);
			    print ">$header1\n$longkeep\n";
			}
			$rprimerfound++;
		    } else {
			die "No primer sequence $rprimer\n";
		    }
		}
	    }
	} else {
	    die "Missing primer sequence $fprimer\n";
	}
    }

    die "Can't find primer for $sequence\n" unless ($fprimerfound);

}
close (IN1);

sub revcomp{
    my ($rc_seq);
    (${rc_seq}) = @_;
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
