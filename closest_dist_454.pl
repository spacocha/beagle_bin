#! /usr/bin/perl
#
#

	die "Usage: dist  > redirect\n" unless (@ARGV);
	($file1) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);

open (IN1, "<$file1") or die "Can't open $file1\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($name1, $name2, $dist)=split(" ", $line1);
    #one must be a mock
    next unless ($name1=~/_[0-9]_[0-9]_[0-9]/ || $name2=~/_[0-9]_[0-9]_[0-9]/);
    #both can't be mocks
    next if ($name1=~/_[0-9]_[0-9]_[0-9]/ && $name2=~/_[0-9]_[0-9]_[0-9]/);
    #which is mock?
    if ($name1=~/_[0-9]_[0-9]_[0-9]/){
	#1 is the mock
	$mock=$name1;
	$test=$name2;
    } elsif ($name2=~/_[0-9]_[0-9]_[0-9]/){
	$mock=$name2;
	$test=$name1;
    } else {
	die "Messed something up\n";
    }
    $alltest{$test}++;
    $distmat{$test}{$mock}=$dist;
}
close (IN1);
foreach $test (sort keys %distmat){
    foreach $mock (sort {$distmat{$test}{$a} <=> $distmat{$test}{$b}} keys %{$distmat{$test}}){
	print "$test\t$mock";
	$dist=$distmat{$test}{$mock};
	foreach $othermock (sort {$distmat{$test}{$a} <=> $distmat{$test}{$b}} keys %{$distmat{$test}}){
	    next if ($othermock eq $mock);
	    if ($distmat{$test}{$mock} == $distmat{$test}{$othermock}){
		print ",$othermock";
	    } elsif ($distmat{$test}{$othermock} < $distmat{$test}{$mock}){
		die "Not sorting\n";
	    } else {
		last;
	    }
	}
	last;
    }
    print "\t$dist\n";
}
