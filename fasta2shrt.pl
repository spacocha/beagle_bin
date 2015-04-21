#! /usr/bin/perl -w

die "Usage: fasta filesize  count_needed > redirect output\n" unless (@ARGV);
($file, $size, $count) = (@ARGV);
chomp ($file);
chomp ($size);
chomp ($count);

$i = 1;
until ($i > $count){
    $got = ();
    until ($got){
	($random) = int(rand($size));
	if ($hash{$random}){
	    $got=();
	} else {
	    $hash{$random}++;
	    $got++;
	}
    }
    $i++;
}

$/=">";
$i=1;
open (IN1, "<$file" ) or die "Can't open $file\n";
while ($line =<IN1>){
    chomp ($line);
    next unless ($line);
    if ($hash{$i}){
	($name, @pieces)=split ("\n", $line);	
	($seq)= join ("", @pieces);
	print ">$name\n$seq\n";
    }
    $i++;
} 
close (IN1);

