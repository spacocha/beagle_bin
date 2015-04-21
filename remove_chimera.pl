#! /usr/bin/perl -w
#
#

	die "Usage: uchime_output final_mat final_fa output\n" unless (@ARGV);
	($file1, $file2, $file3, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($file2);
chomp ($file3);
chomp ($output);


open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next unless ($line=~/Y$/);
    ($number, $OTU)=split ("\t", $line);
    ($newOTU)=$OTU=~/^(.+)\/ab=/;
    $changehash{$newOTU}++;
}
close (IN);
open (MAT, ">${output}.mat") or die "Can't open ${output}.mat\n";

open (IN, "<$file2") or die "Can't open $file2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @libs)=split ("\t", $line);
    print MAT "$line\n" unless ($changehash{$OTU});

}
close (IN);

$/=">";

close (MAT);

open (FA, ">${output}.fa") or die "Can't open ${output}.fa\n";

open (IN, "<$file3") or die "Can't open $file2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @libs)=split ("\n", $line);
    print FA ">$line\n" unless ($changehash{$OTU});

}
close (IN);

