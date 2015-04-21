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
	$transhash{$info}=$hash{$sequence};
    } else {
	$hash{$sequence}=$info;
    }
    
}

close (IN);

open (FA, ">${output}.fa") or die "Can't open ${output}.fa\n";
foreach $seq (keys %hash){
    print FA ">$hash{$seq}\n$seq\n";
    print TRANS "$hash{$seq}\t";
    foreach $otherseq (sort keys %transhash){
	print TRANS "$otherseq\t" if ($transhash{$otherseq} eq $hash{$seq});
    }
    print TRANS "\n";
}
close (FA);
close (TRANS);
