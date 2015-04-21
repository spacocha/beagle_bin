#! /usr/bin/perl -w
#
#

	die "Use this program to take the UCLUST groups and make a consensus (> 75% identity) sequence to run through chimera checker
Usage: UC_output UC_group concat > redirect output\n" unless (@ARGV);
	($file1, $file2, $file3) = (@ARGV);

	die "Please follow command line args\n" unless ($file3);
chomp ($file1);
chomp ($file2);
chomp ($file3);

open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($UCgroup, $long, $FCgroup, $parentseq, $seq) = split ("\t", $line);
    if ($UCgroup eq $file2){
	($name) = $long =~/^(.+)\/[12]$/;
	$hash{$name}++;
    }
}
close (IN);

$/=">";
open (IN, "<$file3") or die "Can't open $file3\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($ucinfo, @seqs) = split ("\n", $line);
    $sequence = join ("", @seqs);
    $seqhash{$ucinfo}=$sequence;
}
close (IN);

foreach $name (keys %hash){
    if ($seqhash{$name}){
	$sequence = $seqhash{$name};
	(@pieces) = split ("", $sequence);
	$j = @pieces;
	$i = 1;
	until ($i > $j){
	    $k = $i-1;
	    $consensus{$i}{$pieces[$k]}++;
	    $i++;
	}
    } else {
	die "Doesn't have a sequence $name\n";
    }

}
    print ">${file1}_con\n";
    foreach $pos (sort {$a <=> $b} keys %consensus){
	$total = 0;
	foreach $base (sort keys %{$consensus{$pos}}){
	    $total+= $consensus{$pos}{$base};
	}
	$printed=();
	foreach $base (sort keys %{$consensus{$pos}}){
	    $percent = $consensus{$pos}{$base}/$total;
	    if ($percent > 0.75){
		print "$base";
		$printed++;
		last;
	    }
	}
	print "N" unless ($printed);
    }
    print "\n";
