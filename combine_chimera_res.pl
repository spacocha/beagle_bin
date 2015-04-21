#! /usr/bin/perl -w

die "Usage: list_of_chimera_res > redirect\n" unless (@ARGV);

($list)=(@ARGV);
chomp ($list);
open (LIST, "<$list" ) or die "Can't open $list\n";
while ($line =<LIST>){
    chomp ($line);
    next unless ($line);
    if ("-e $line"){
	open (IN, "<$line" ) or die "Can't open $line\n";
	while ($line =<IN>){
	    chomp ($line);
	    next unless ($line);
	    ($num, $comiso)=split ("\t", $line);
	    ($trueiso)=$comiso=~/^(.+)\/ab=/;
	    if ($line=~/Y$/){
		$hash{$trueiso}++;
	    }
	}
	close (IN);
    } else {
	print "$line doesn't exist\n";
    }
}
close (LIST);

foreach $iso (sort keys %hash){
    print "$iso\trec\n";
}
