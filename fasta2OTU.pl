#! /usr/bin/perl -w
#
#

	die "Use this to combined identical sequences in a fasta file
Usage: fasta_file outputname\n" unless (@ARGV);
	($file2, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file2);
chomp ($output);

$/ = ">";
open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, @seqs)=split ("\n", $line);
		($library, $read, @extras)=split (" ", $name);
		if ($read=~/^.+\/[0-9]/){
		    ($shortname)=$read=~/^(.+)\/[0-9]/;
		    $name=$shortname;
		} else {
		    $name=$read;
		}
		next unless ($name);
		$sequence = join ("", @seqs);
		print "MISSING SEQUENCE: $line $sequence\n"  unless ($sequence);
		if ($hash{$sequence}){
		    #don't repeat
		    $namehash{$name}=$hash{$sequence};
		    $totalhash{$sequence}++;
		} else {
		    $hash{$sequence}=$name;
		    $namehash{$name}=$name;
		    $totalhash{$sequence}++;
		}
       	}
close (IN);

open (OUT, ">${output}.fa") or die "Can't open ${output}.fa\n";
open (TRANS, ">${output}.trans") or die "Can't open ${output}.trans\n";
$i=1;
foreach $seq (sort {$totalhash{$b} <=> $totalhash{$a}} keys %totalhash){
    $oldname=$hash{$seq};
    $newname="ID"."$i"."P";
    print OUT ">$newname\n$seq\n";
    $old2new{$oldname}=$newname;
    $i++;
}

foreach $name (sort keys %namehash){
    print TRANS "$name\t$old2new{$namehash{$name}}\n";
}
    
close (OUT);
close (TRANS);
