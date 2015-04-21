 #! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: <input_file> output\n" unless (@ARGV);
	
($file, $output) = (@ARGV);
die "Please follow command line args\n" unless ($output);
chomp ($file);
chomp ($output);
$/ = ">";
open (TRANS, ">${output}.trans") or die "Can't open ${output}.trans\n";
open (IN, "<$file") or die "Can't open $file\n";
while ($line1 = <IN>){	
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    ($sequence) = join ("", @pieces);
    $sequence =~tr/\n//d;
    $sequence =~tr/U/T/d;
    if ($hash{$sequence}){
	#it already exists, so just output to table
	#check which lib
	($lib)=$info=~/^HWUS.+([ATGC]{7})$/;
	$count{$sequence}{$lib}++;
	$alllib{$lib}++;
    } else {
	$hash{$sequence}=$info;
	($lib)=$info=~/^HWUS.+([ATGC]{7})$/;
	$count{$sequence}{$lib}++;
    }
    
}

close (IN);
foreach $seq (keys %hash){
    print TRANS "Info";
    foreach $lib (sort keys %alllib){
        print TRANS "\t$lib";
    }
    print TRANS "\n";
    last;
}

open (FA, ">${output}.fa") or die "Can't open ${output}.fa\n";
foreach $seq (keys %hash){
    print FA ">$hash{$seq}\n$seq\n";
    print TRANS "$hash{$seq}";
    foreach $lib (sort keys %alllib){
	$count{$seq}{$lib}=0 unless ($count{$seq}{$lib});
	print TRANS "\t$count{$seq}{$lib}";
    }
    print TRANS "\n";
}
close (FA);
close (TRANS);
