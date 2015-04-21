#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: fa1 fa2 > Redirect output\n" unless (@ARGV);
	
chomp (@ARGV);
($file, $file2) = (@ARGV);
$/ = ">";
open (IN, "<$file") or die "Can't open $file\n";
while ($line1 = <IN>){	
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    ($sequence) = join ("", @pieces);
    $sequence =~tr/\n//d;
    $hash{$sequence}{$file}=$info;
	
}

close (IN);


open (IN, "<$file2") or die "Can't open $file2\n";
while ($line1 = <IN>){
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    ($sequence) = join ("", @pieces);
    $sequence =~tr/\n//d;
    $hash{$sequence}{$file2}=$info;
}
close (IN);

foreach $seq (sort keys %hash){
    unless ($hash{$seq}{$file} && $hash{$seq}{$file2}){
	$hash{$seq}{$file}="NA" unless ($hash{$seq}{$file});
	$hash{$seq}{$file2}="NA"unless ($hash{$seq}{$file2});
	print "$seq\t$file\t$hash{$seq}{$file}\t$file2\t$hash{$seq}{$file2}\n";
    }
}
