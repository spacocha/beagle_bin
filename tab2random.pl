#! /usr/bin/perl -w

die "Usage: tab filesize count_needed> redirect" unless (@ARGV);
($tab, $size, $count) = (@ARGV);
chomp ($tab);
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

$i=1;
open (IN1, "<$tab" ) or die "Can't open $tab\n";
while ($line =<IN1>){
    chomp ($line);
    next unless ($line);
    if ($hash{$i}){
	print "$line\n";
    }
    $i++;
} 
close (IN1);

