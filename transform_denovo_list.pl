#! /usr/bin/perl -w

die "Usage: list cutoff > redirect\n" unless (@ARGV);

($list, $cutoff)=(@ARGV);
chomp ($list);
chomp ($cutoff);


open (IN, "<$list" ) or die "Can't open $list\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/unique/);
    ($level, $number, @groups)=split ("\t", $line);
    if ($level==$cutoff){
	foreach $group (@groups){
	    ($name, @OTUs)=split (",", $group);
	    print "$name";
	    foreach $OTU (@OTUs){
		print "\t$OTU";
	    }
	    print "\n";
	}
    }
}
close (IN);

