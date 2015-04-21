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
	until ($i >=$j){
	    foreach $lib (sort keys %{$mathash{$OTU}}){
		$mismatchhash{$lib}{$i}{$sbases[$i]}+=$mathash{$OTU}{$lib} unless ($sbases[$i] eq $rbases[$i]);
		$totalbases{$lib}{$i}+=$mathash{$OTU}{$lib};
		$allbases{$sbases[$i]}++;
		$allbases{$rbases[$i]}++;
	    }
	    $i++;
	}
    } else {
	print "Missing something: seqhash $seqhash{$OTU} $OTU or mockhash $ref $mockhash{$ref}\n";
    }
}
close (IN);

foreach $lib (sort keys %mismatchhash){
    #only make it for one lib at a time
    print "$lib\n";
    print "";
    foreach $base (sort keys %allbases){
	print "\t$base";
    }
    print "\n";
    foreach $pos (sort {$a <=> $b} keys %{$mismatchhash{$lib}}){
	print "$pos";
	foreach $base (sort keys %allbases){
	    if ($totalbases{$lib}{$pos}){
		if ($mismatchhash{$lib}{$pos}{$base}){
		    $fractot=$mismatchhash{$lib}{$pos}{$base}/$totalbases{$lib}{$pos};
		    print "\t$fractot";
		} else {
		    print "\t0";
		}
	    } else {
		print "\tNA";
	    }
	}
	print "\n";
    }
}
