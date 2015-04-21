#! /usr/bin/perl -w

die "Usage: fasta count_needed > redirect output\n" unless (@ARGV);
($file, $count) = (@ARGV);
chomp ($file);
chomp ($count);

$/=">";
open (IN1, "<$file" ) or die "Can't open $file\n";
while ($line =<IN1>){
    chomp ($line);
    next unless ($line);
    $size++;
}
close (IN1);

$/="\n";
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
