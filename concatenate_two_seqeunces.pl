#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Use this program on QIIME formatted data
Usage: <forward> <reverse read> > Redirect output\n" unless (@ARGV);
	
chomp (@ARGV);
($ffile, $rfile) = (@ARGV);
$/ = ">";
open (IN, "<$ffile") or die "Can't open $ffile\n";
while ($line1 = <IN>){	
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    ($sequence) = join ("", @pieces);
    $sequence =~tr/\n//d;
    ($shrtinfo)=$info=~/^(.+?)\s/;
    die "$info\n" unless ($shrtinfo);
    $seqhash{$shrtinfo}=$sequence;
}

close (IN);
open (IN, "<$rfile") or die "Can't open $rfile\n";
while ($line1 = <IN>){
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    ($sequence) = join ("", @pieces);
    $sequence =~tr/\n//d;
    ($shrtinfo)=$info=~/^(.+?)\s/;
    die "$info\n" unless ($shrtinfo);
    if ($seqhash{$shrtinfo}){
	print ">${info}\n${seqhash{$shrtinfo}}${sequence}\n";
    }
}
close (IN);


############
#subroutines of very common use
############

sub revcomp{
    (@pieces) = split ("", $rc_seq);
    #make reverse complement
    %revcomphash=(
	"A" => "T", 
	"T" => "A", 
	"U" => "A",
	"G" => "C",
	"C" => "G",
	"Y" => "R",
	"R" => "Y",
	"S" => "S",
	"W" => "W",
	"K" => "M",
	"M" => "K",
	"B" => "V",
	"D" => "H",
	"H" => "D",
	"V" => "B",
	"N" => "N",
	"a" => "t",
	"t" => "a",
	"u" => "a",
	"g" => "c",
	"c" => "g",
	"y" => "r",
	"r" => "y",
	"s" => "s",
	"w" => "w",
	"k" => "m",
	"m" => "k",
	"b" => "v",
	"d" => "h",
	"h" => "d",
	"v" => "b",
	"n" => "n"
	);
    $j = @pieces;
    $j-=1;
    $seq = ();
    until ($j < 0){
	if ($pieces[$j]){
	    if ($revcomphash{$pieces[$j]}){
		if ($seq){
		    $seq = "$seq". "$revcomphash{$pieces[$j]}";
		} else {
		    $seq = "$revcomphash{$pieces[$j]}";
		}
	    } else {
		die "No revcomp base for $pieces[$j] $revcomphash{$pieces[$j]}\n";
	    }
	} else {
	    die "NO j $j\n";
	}
	$j--;
    }
    return ($seq);
}

1;
