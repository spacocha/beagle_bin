#! /usr/bin/perl -w

die "Usage: .mat > redirect\n" unless (@ARGV);
($mat) = (@ARGV);
chomp ($mat);

$first=1;
open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @pieces)=split ("\t", $line);
    if ($first){
	$first=0;
	$j=@pieces;
	$i=0;
	until ($i>=$j){
	    $header{$i}=$pieces[$i];
	    $i++;
	}
    } else {
	die "$line\n";
	$j=@pieces;
	$i=0;
	until ($i>=$j){
            $hash{$i}{$name}=$pieces[$i];
	    $sumhash{$name}+=$pieces[$i];
	    $i++;
	}
    }
	
 }
close (IN);

foreach $hi (sort {$hash{$a} <=> $hash{$b}} keys %hash){
    foreach $name (sort {$b <=> $a} keys %sumhash){
	die "$name\t$sumhash{$name}\n";

    }
}
