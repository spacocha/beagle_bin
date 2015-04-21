#! /usr/bin/perl -w

die "Usage: <tab_file> <fasta_file> > redirect" unless (@ARGV);
($tabfile, $fastafile) = (@ARGV);
chomp ($tabfile);
chomp ($fastafile);

open (IN, "<$tabfile" ) or die "Can't open $tabfile\n";
while ($line =<IN>){
    chomp ($line);
    ($name, $trans)=split ("\t", $line);
    $hash{$name}=$trans;
}
close (IN);

$/=">";
open (IN, "<$fastafile" ) or die "Can't open $fastafile\n";
while ($line =<IN>){
    chomp ($line);
    ($name, @seqs)=split ("\n", $line);
    next unless ($name);
    ($newname) = $name =~/^[0-9]+\|\*\|(.+)$/;
    ($seq) = join ("", @seqs);
    if ($hash{$newname}){
	print ">$hash{$newname}\n$seq\n";
    } else {
	die "What NAME $name NEWNAME $newname\n";
    }
}
close (IN)
