#! /usr/bin/perl -w

die "Usage: file > redirect\n" unless (@ARGV);

($mat)=(@ARGV);
chomp ($mat);
open (IN, "<$mat" ) or die "Can't open $mat\n";
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($cutoff, @p)=split ("\t", $line);

    if ($cutoff == 0.1){
	$total=@p;
	foreach $newp (@p){
	    print "$newp\n";
	}
	die;
	print "$cutoff\t$total\n";
    }
}
close (IN);


