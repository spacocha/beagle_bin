#! /usr/bin/perl -w
#
#

	die "Usage: uchime_output final_fa> redirect\n" unless (@ARGV);
	($file1, $file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file1);
chomp ($file2);


open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next unless ($line=~/Y$/);
    ($number, $OTU)=split ("\t", $line);
    if ($OTU=~/^.+\/ab=[0-9]+\//){
	($newOTU)=$OTU=~/^(.+)\/ab=[0-9]+\/$/;
    } else {
	$newOTU=$OTU;
    }
    $changehash{$newOTU}++;
}
close (IN);
$/=">";
open (IN, "<$file2") or die "Can't open $file2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @seqs)=split ("\n", $line);
    if ($OTU=~/^.+\/ab=[0-9]+\//){
        ($newOTU)=$OTU=~/^(.+)\/ab=[0-9]+\/$/;
    } else {
        $newOTU=$OTU;
    }
    ($sequence)=join ("", @seqs);
    print ">$OTU\n$sequence\n" unless ($changehash{$OTU});

}
close (IN);

