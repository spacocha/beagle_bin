#! /usr/bin/perl -w

die "Usage: scrap> redirect\n" unless (@ARGV);
($merge) = (@ARGV);
chomp ($merge);

$/=">";
open (IN, "<$merge" ) or die "Can't open $merge\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @pieces)=split ("\n", $line);
    ($sequence)=join ("", @pieces);
    if ($info=~/\|f/){
	if ($sequence=~/GTGCCAGC[AC]GCCGCGG.../){
	    #sequence has the right primer structure
	    ($diversity)=$sequence=~/^(.*)GTGCCAGC[AC]GCCGCGG.../;
	    if ($diversity){
		(@divpiece)=split ("", $diversity);
		$divlen=@divpiece;
		$hashdivlen{$divlen}++;
	    } else {
		$hashdivlen{"NA"}++;
	    }
	} else {
	    $hashdivlen{"Primer"}++;
	}

    }
}
close (IN);

foreach $type (sort {$a <=> $b} keys %hashdivlen){
    print "$type\t$hashdivlen{$type}\n";
}
