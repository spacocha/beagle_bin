#! /usr/bin/perl -w
#
#

	die "Usage: <UC File> <FA file> > output\n" unless (@ARGV);
	($file, $fa) = (@ARGV);

	die "Please follow command line args\n" unless ($fa);
chomp ($file);
chomp ($fa);

	open (IN, "<$file") or die "Can't open $file\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line=~/^C/);
		($type, $cluster, $size, $ID, $strand, $temp1, $temp2, $align, $query, $target)=split("\t", $line);
		if ($type eq "C"){
		    $namehash{$query}=$cluster;
		}
       	}
	close (IN);

$/=">";

open (IN, "<$fa") or die "Can't open $fa\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @seqs)= split ("\n", $line);
    ($seed)=$name=~/^>*(.+)$/;
    ($sequence)=join ("", @seqs);
    print ">${namehash{$seed}}|*|${seed}\n${sequence}\n" if ($namehash{$seed});
}

