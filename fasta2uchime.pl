#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: mat fasta output\n" unless (@ARGV);
	
	chomp (@ARGV);
	($mat, $file, $output) = (@ARGV);
$first=1;
open (IN, "<$mat") or die "Can't open $mat\n";
while ($line1 = <IN>){
    chomp ($line1);
    next unless ($line1);
    ($info, @pieces) = split ("\t", $line1);
    if ($first){
	@headers=@pieces;
	$first=();
    } else {
	if ($info=~/_[0-9]+$/){
	    ($newinfo)=$info=~/^(.+)_[0-9]+$/;
	} else {
	    $newinfo=$info;
	}
	$j = @pieces;
	$i=0;
	until ($i>=$j){
	    $mathash{$newinfo}{$headers[$i]}=$pieces[$i];
	    $i++;
	}
    }
}
close (IN);
foreach $piece (@headers){
    open ($piece, ">${output}.${piece}") or die "Can't open ${output}.${piece}\n";
}
	$/ = ">";
	open (IN, "<$file") or die "Can't open $file\n";
while ($line1 = <IN>){	
    chomp ($line1);
    next unless ($line1);
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    ($sequence)=join ("", @pieces);
    if ($info=~/_[0-9]+/){
	($newinfo)=$info=~/^(.+)_[0-9]+$/;
    } else {
	$newinfo=$info;
    }
    foreach $header (@headers){
	print $header ">${newinfo}/ab=$mathash{$newinfo}{$header}/\n$sequence\n" if ($mathash{$newinfo}{$header});
    }
}
	
close (IN);
foreach $header (@headers){
    close ($header);
}
	
