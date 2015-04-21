#! /usr/bin/perl -w
#
#Use this program to make tab files for FileMaker
#

die "Usage: fasta prefix\n" unless (@ARGV);

chomp (@ARGV);
($file, $prefix) = (@ARGV);
die "Please follow command line options\n" unless ($prefix);
chomp ($prefix);

$/ = ">";
open (IN, "<$file") or die "Can't open $file\n";
open (FA, ">${prefix}.fa") or die "Can't open ${prefix}.fa\n";
open (FAIL, ">${prefix}.fail") or die "Can't open ${prefix}.fail\n";
while ($line1 = <IN>){
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    ($sequence) = join ("", @pieces);
    $sequence =~tr/\n//d;
    if ($sequence=~/^.{0,9}GTGCCAGC.GCCGCG.....+....GA.ACCC..GTAGTCC.{0,9}$/){
	($begin, $fprimer, $seq, $rprimer, $end)=$sequence=~/^(.{0,9})(GTGCCAGC.GCCGCG....)(.+)(....GA.ACCC..GTAGTCC)(.{0,9})$/;
	if ($seq){
	    print FA ">$info\n$seq\n";
	} else {
	    print FAIL ">$info\n$sequence\n";
	}
    } elsif ($sequence=~/^.{0,9}GGACTAC..GGGT.TC....+....CGCGGC.GCTGGCAC.{0,9}$/){
	($begin, $fprimer, $seq, $rprimer, $end)=$sequence=~/^(.{0,9})(GGACTAC..GGGT.TC....)(.+)(....CGCGGC.GCTGGCAC)(.{0,9})$/;
        if ($seq){
	    ($rc_seq)=revcomp($seq);
            print FA ">$info\n$rc_seq\n";
        } else {
            print FAIL ">$info\n$sequence\n";
        }
    } else {
	print FAIL ">$info\n$sequence\n";
    }
}

close (IN);


sub revcomp{
    my ($rc_seq);
    my ($seq);
    my (@pieces);
    my ($j);
    (${rc_seq}) = @_;
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
	    die "No revcomp base for $pieces[$j] $revcomphash{$pieces[$j]}\n
";
	}
    } else {
	die "NO j $j\n";
    }
    $j--;
}
return ($seq);
}
