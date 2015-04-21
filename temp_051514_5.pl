#! /usr/bin/perl -w

die "Usage: NCBI_trans mark_trans fasta> redirect\n" unless (@ARGV);
($NCBItrans, $trans, $fasta) = (@ARGV);
chomp ($NCBItrans, $trans, $fasta);

open (IN, "<$NCBItrans" ) or die "Can't open $NCBItrans\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    #just record the taxIDs that are needed
    $hash{$pieces[1]}++;
}

close (IN);

open (IN, "<$trans" ) or die "Can't open $trans\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($head, $id, $fullname)=split ("\t", $line);
    if ($hash{$id}){
	$fullname=~s/[^\w]/_/g;
	($target)=$fullname=~s/__/_/g;
	$namehash{$fullname}++;
    }
}
close(IN);

$/=">";
open (IN, "<$fasta" ) or die "Can't open $fasta\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @seqs)=split ("\n", $line);
    if ($namehash{$name}){
	($sequence)=join ("",  @seqs);
	print ">$name\n$sequence\n";
    }
}
close (IN);
