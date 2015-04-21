#! /usr/bin/perl -w
#
#

	die "Usage: aligned_file start_pos len output\n" unless (@ARGV);
	($file2, $start, $len, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file2);
chomp ($start);
chomp ($len);
chomp ($output);

$/ = ">";
$OTUc=1;
open (OUT, ">${output}.trans") or die "Can't open ${output}.trans\n";
open (IN, "<$file2") or die "Can't open $file2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @seqs)=split ("\n", $line);
    next unless ($name);
    if ($name=~/^(.+)_([0-9]+)$/){
	($OTU, $abund)=$name=~/^(.+)_([0-9]+)$/;
    } else {
	$OTU=$name;
	$abund=1;
    }
    $sequence = join ("", @seqs);
    ($shrt)=$sequence=~/^.{${start}}(.{${len}})/;
    if ($shrt=~/^[AGCTU-]+$/){
	#if there are no gaps
	#now make OTUs too
	$longshrt=$shrt;
	$shrt=~s/-//g;
	if ($namehash{$shrt}){
	    #it already has an entry
	    print OUT "$OTU\t$namehash{$shrt}\n";
	    $abundhash{$shrt}+=$abund;
	} else {
	    (@piecesc) = split ("", $OTUc);
	    $these = @piecesc;
	    $zerono = 7 - $these;
	    $zerolet = "0";
	    $zeros = $zerolet x $zerono;
	    $OTUn="ID${zeros}${OTUc}P";
	    $OTUc++;
	    $namehash{$shrt}=$OTUn;
	    $abundhash{$shrt}=$abund;
	    $longhash{$shrt}=$longshrt;
	    print OUT "$OTU\t$namehash{$shrt}\n";
	}
    } else {
	#it didn't get aligned
	print OUT "$OTU\tremoved\n";
    }
    
}
close (IN);
close (OUT);

open (OUT, ">${output}.fa") or die "Can't open ${output}.fa\n";
foreach $seq (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
    print OUT ">$namehash{$seq}_${abundhash{$seq}}\n$longhash{$seq}\n";
}
