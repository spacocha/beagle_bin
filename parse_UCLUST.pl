#! /usr/bin/perl -w
#
#

	die "Usage: <File> > output\n" unless (@ARGV);
	($file) = (@ARGV);

	die "Please follow command line args\n" unless ($file);
chomp ($file);
	open (IN, "<$file") or die "Can't open $file\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($type, $cluster, $size, $ID, $strand, $temp1, $temp2, $align, $query, $target)=split("\t", $line);
		$hash{$query}=$cluster;
		$clusterhash{$cluster}++;
		if ($type eq "S"){
		    $namehash{$cluster}=$query;
		}
       	}
	close (IN);

foreach $cluster (sort {$clusterhash{$b} <=> $clusterhash{$a}} keys %clusterhash){
    print "$cluster\t$namehash{$cluster}\t$clusterhash{$cluster}\n";
}
