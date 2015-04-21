#! /usr/bin/perl -w

die "Use this to remove the ;size=[0-9]+ from the header of a fasta file
Usage: <fasta_file> > redirect\n" unless (@ARGV);
($fastafile) = (@ARGV);
chomp ($fastafile);

$/=">";
open (IN, "<$fastafile" ) or die "Can't open $fastafile\n";
while ($line =<IN>){
    chomp ($line);
    ($name, @seqs)=split ("\n", $line);
    next unless ($name);
    ($newname) = $name =~/^(.+);size=/;
    die "Is there a size= in the header? $name\n" unless ($newname);
    ($seq) = join ("", @seqs);
    print ">${newname}\n$seq\n";
}
close (IN)
