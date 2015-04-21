#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: trans input_file > Redirect output\n" unless (@ARGV);
	
chomp (@ARGV);
($trans, $file) = (@ARGV);
open (IN, "<$trans") or die "Can't open $trans\n";
while ($line1 = <IN>){
    chomp ($line1);
    next unless ($line1);
    (@pieces)=split("\t", $line1);
    die "Doesn't have a trnaslation $pieces[10] $pieces[0]\n" unless ($pieces[0] || $pieces[10]);
    $hash{$pieces[10]}=$pieces[0];

}
close (IN);

$/ = ">";
open (IN, "<$file") or die "Can't open $file\n";
while ($line1 = <IN>){	
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    if ($info=~/sample=.+;[0-9]/){
	($check, $end)=$info=~/^sample=(.+)(;[0-9].+$)/;
	if ($hash{$check}){
	    ($sequence) = join ("", @pieces);
	    $sequence =~tr/\n//d;
	    print ">sample=$hash{$check}${end}\n$sequence\n";
	} else {
	    die "No translation $check\n";
	}
    } else {
	die "Different $line1\n";
    }
}
close (IN);

	
