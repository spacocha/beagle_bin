#! /usr/bin/perl -w
#
#

	die "Use this program to calculate baes freqs in seq data
Usage: tab namecol seqcol> Redirect\n" unless (@ARGV);
	($file2, $namecol, $seqcol) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file2);
chomp ($seqcol);
chomp ($namecol);
$namecolm1=$namecol-1;
$seqcolm1=$seqcol-1;


#make a table of total counts per seed cluster
    open (IN, "<${file2}") or die "Can't open ${file2}\n";
    while ($line = <IN>){
	chomp ($line);
	next unless ($line);
	(@fields) = split ("\t", $line);
	#record position and base information for all of the sequences
	next unless ($fields[$seqcolm1]);
	($sequence) = $fields[$seqcolm1];
	$seqhash{$sequence}++;
	$namehash{$sequence}=$fields[$namecolm1];
	(@pieces)=split ("", $sequence);
	$total = @pieces;
	$i = 0;
	until ($i >= $total){
	    if ($pieces[$i] eq "."){
		#die "$i is a dot: $pieces[$i]\n";
	    } else {
		#die "$i is not a dot $pieces[$i]\n";
		$polyhash{$i}++;
	    }
	    $polyhashtotal{$i}++;
	    $i++;
	}
    }
close (IN);

foreach $position (sort {$a <=> $b} keys %polyhash){
    if ($polyhash{$position}){
	$freq = 100*$polyhash{$position}/$polyhashtotal{$position};
    } else {
	$freq=0;
    }
    print "$position\t$freq\n"; 

}

