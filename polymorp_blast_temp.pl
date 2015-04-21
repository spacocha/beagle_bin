#! /usr/bin/perl -w
#
#

	die "Use this program to take blast in table for and look to see where it differs
from the reference sequence
Usage: blast ref fasta mat > Redirect\n" unless (@ARGV);
	($blast, $ref, $fasta, $mat) = (@ARGV);
	die "Please follow command line args\n" unless ($fasta);
chomp ($blast);
chomp ($ref);
chomp ($fasta);
chomp ($mat);

$/=">";
open (IN, "<${ref}") or die "Can't open ${ref}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs)=split ("\n", $line);
    ($sequence)=join ("", @seqs);
    $mockhash{$info}=$sequence;
}
close (IN);

open (IN, "<${fasta}") or die "Can't open ${fasta}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs)=split("\n", $line);
    ($sequence)=join ("", @seqs);
    $seqhash{$info}=$sequence;
}
close (IN);

$/="\n";
open (IN, "<${mat}") or die "Can't open ${mat}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if (@headers){
	$i=0;
	$j=@pieces;
	until ($i >=$j){
	    $mathash{$OTU}{$headers[$i]}=$pieces[$i];
	    $i++;
	}
    } else {
	(@headers)=@pieces;
    }
}
close (IN);

open (IN, "<${blast}") or die "Can't open ${blast}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, $ref, @pieces)=split ("\t", $line);
    next if ($done{$OTU});
    $done{$OTU}++;
    if ($seqhash{$OTU} && $mockhash{$ref}){
	(@sbases)=split ("", $seqhash{$OTU});
	(@rbases)=split ("", $mockhash{$ref});
	$j=@sbases;
	$k=@rbases;
	die "They don't match $OTU $j $seqhash{$OTU} $ref $k\n" unless ($j == $k);
	$i=0;
	$basemis=0;
	until ($i >=$j){
	    unless ($sbases[$i] eq $rbases[$i]){
		$basemis++;
	    }
	    $i++;
	}

	if ($largestmis){
	    $largestmis=$basemis if ($basemis > $largestmis);
	} else {
	    $largestmis =$basemis;
	}
	foreach $lib (sort keys %{$mathash{$OTU}}){
	    $mishash{$lib}{$basemis}+=$mathash{$OTU}{$lib};
	}
    } else {
	print "Missing something: seqhash $seqhash{$OTU} $OTU or mockhash $ref $mockhash{$ref}\n";
    }
}
close (IN);

foreach $lib (sort keys %mishash){
    print "lib";
    $i=0;
    $j = $largestmis;
    until ($i >=$largestmis){
	print "\t$i";
	$i++;
    }
    print "\n";
    last;
}

foreach $lib (sort keys %mishash){
    print "$lib";
    $i=0;
    $j = $largestmis;
    until ($i >=$largestmis){
	if ($mishash{$lib}{$i}){
	    print "\t$mishash{$lib}{$i}";
	} else {
	    print "\t0";
	}
	$i++;
    }
    print "\n";
}
