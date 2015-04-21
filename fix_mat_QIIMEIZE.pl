#! /usr/bin/perl
#
#

	die "Usage: <fasta> <mat> > redirect\n" unless (@ARGV);
	($file1, $file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file1);
chomp ($file2);

$/=">";
open (IN1, "<$file1") or die "Can't open $file1\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($parent)=split("\n", $line1);
    ($first, $second)=split (" ", $parent);
    $hash{$second}=$parent;
}
close (IN1);

$/="\n";
$first=1;
open (IN1, "<$file2") or die "Can't open $file2\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($parent, $total, @groups)=split("\t", $line1);
    if ($first){
	print "$parent";
	foreach $group (@groups){
	    print "\t$group";
	}
	print "\n";
	$first=();
    } else {
	if ($hash{$parent}){
	    print "$hash{$parent}";
	    foreach $group (@groups){
		print "\t$group";
	    }
	} else {
	    die "Missing $parent\n";
	}
	print "\n";
    }
}
close (IN1);
