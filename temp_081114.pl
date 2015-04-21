#! /usr/bin/perl -w

die "Usage: map map_mat parallel_mat> redirect\n" unless (@ARGV);
($merge, $matmap, $mat) = (@ARGV);
chomp ($merge, $mat);

$first=1;
open (IN, "<$matmap" ) or die "Can't open $matmap\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($mock, $count)=split ("\t", $line);
    if ($first){
        $first=();
    } else {
	$mapcount{$mock}=$count;
    }
}

close (IN);
open (IN, "<$merge" ) or die "Can't open $merge\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($mock, $map, $seq1, $seq2)=split ("\t", $line);
    die "Missing mapcount $mock\n" unless ($mapcount{$mock});
    $hash{$map}+=$mapcount{$mock};
}
close (IN);

$first=1;
open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($mock, @pieces)=split ("\t", $line);
    if ($first){
	print "$mock";
	foreach$piece (@pieces){
            print "\t$piece";
	    @headers=@pieces;
	}
	print "\n";
	$first=();
    } else {
	if ($hash{$mock}){
	    print "$mock";
	    foreach$piece (@pieces){
		print "\t$piece";
	    }
	    print "\t$hash{$mock}\n";
	}
    }
}

close (IN);

