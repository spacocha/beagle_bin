#! /usr/bin/perl
#
#

	die "Usage: <Solexa File1> > redirect\n" unless (@ARGV);
	($file1) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);


$/="@";
$count=1;
$lnum=1;
#open the forward file and save for later

open (IN2, "<${file1}") or die "Can't open forward file ${file1}\n";
	while ($line=<IN2>){
		chomp ($line);
		next unless ($line);
		($header, $sequence, $useless1, $qual)=split("\n", $line);
		next unless ($sequence=~/^[ATGC]{8}/);
		($b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8) = $sequence=~/^(.)(.)(.)(.)(.)(.)(.)(.)/;
		$poshash{'1'}{$b1}++;
		$poshash{'2'}{$b2}++;
		$poshash{'3'}{$b3}++;
		$poshash{'4'}{$b4}++;
		$poshash{'5'}{$b5}++;
		$poshash{'6'}{$b6}++;
		$poshash{'7'}{$b7}++;
		$poshash{'8'}{$b8}++;
		($now) = $sequence=~/^(.{4})/;
		($plusone) = $sequence=~/^.(.{4})/;
		($plustwo)=$sequence=~/^..(.{4})/;
		($plusthree)=$sequence=~/^...(.{4})/;
		$nowhash{$now}++;
		$plusonehash{$plusone}++;
		$plustwohash{$plustwo}++;
		$plusthreehash{$plusthree}++;
		$total++;
	}
foreach $pos (sort keys %poshash){
    foreach $base (sort keys %{$poshash{$pos}}){
	$frac = $poshash{$pos}{$base}/$total;
	print "$pos\t$base\t$frac\n";
    }
}

foreach $now (keys %nowhash){
    #what is the fractional distribution for each class?
    $fraction = $nowhash{$now}/$total;
    if ($fraction > 0.01){
	print "NOW: $now $fraction\n";
    }
}

foreach $now (keys %plusonehash){
    #what is the fractional distribution for each class?                                                                                                                                                    
    $fraction = $plusonehash{$now}/$total;
    if ($fraction > 0.01){
	print "Plus one: $now $fraction\n";
    }   
}

foreach $now (keys %plustwohash){
    #what is the fractional distribution for each class?                                                                                                                                                                                                                                 
    $fraction = $plustwohash{$now}/$total;
    if ($fraction > 0.01){
	print "Plus two: $now $fraction\n";
    }   
}

foreach $now (keys %plusthreehash){
    #what is the fractional distribution for each class?                                                                                                                                                                                                                                                                                                                                                       
    $fraction = $plusthreehash{$now}/$total;
    if ($fraction > 0.1){
	print "Plus three: $now $fraction\n";
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
