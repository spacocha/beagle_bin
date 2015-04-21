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
	($shrt)=$sequence=~/^.{87}(.{114})/;
	$seqhash{$shrt}++;
	$namehash{$shrt}=$fields[$namecolm1];
	(@pieces)=split ("", $shrt);
	$total = @pieces;
	$i = 0;
	until ($i >= $total){
	    $polyhash{$i}{$pieces[$i]}++;
	    $polyhashtotal{$i}++;
	    $i++;
	}
    }
close (IN);
%basehash=("A",1,"C", 1,"T", 1, "G", 1, "-",1);
#set the frequency of each base at each position
foreach $position (keys %polyhash){
    print "Position";
    foreach $base (sort keys %basehash){
	print "\t$base";
    }
    print "\n";
    last;
}

foreach $position (sort {$a <=> $b} keys %polyhash){
    print "$position";
    foreach $base (sort keys %basehash){
	$polyhash{$position}{$base} = 0 unless ($polyhash{$position}{$base});
	$freq = $polyhash{$position}{$base}/$polyhashtotal{$position};
	print "\t$freq"; 
    }
    print "\n";
}

