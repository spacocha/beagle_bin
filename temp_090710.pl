#! /usr/bin/perl -w
#
#

	die "Usage: UC_file UC_fasta_input > Redirect\n" unless (@ARGV);
	($file2, $file1) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file2);
chomp ($file1);

open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($type, $seedno, $one, $two, $three, $four, $five, $six, $name, $seedname)=split ("\t", $line);
		if ($type eq "S"){
		    $seedname = $name;
		}
		$hash{$name}=$seedname;
       	}
close (IN);

$/=">";
open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @seqs)=split ("\n", $line);
    ($sequence) = join ("", @seqs);
    if ($hash{$name}){
	if ($hash{$name}=~/^FreClu_parent_seq_2$/){
	    print ">UC2_${line}\n";
	}
    }
}
close (IN);

