#! /usr/bin/perl -w

die "Usage: mock_check\n" unless (@ARGV);
($file1) = (@ARGV);
chomp ($file1);

$/=">";
open (IN, "<$file1" ) or die "Can't open $file1\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($ref, @seqs)=split ("\n", $line);
    ($sequence)=join ("", @seqs);
    $hash{$ref}=$sequence;
}
close (IN);

%counthash=('60','1','70','1','80','1','90','1','100','1');

foreach $ref (sort keys %hash){
    foreach $number (sort keys %counthash){
	($shortseq)=$hash{$ref}=~/^(.{$number})/;
	($quals)=lc($shortseq);
	print ">${ref}:$number\n$shortseq\n";
    }
}
