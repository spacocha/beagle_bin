#! /usr/bin/perl -w

die "Usage: file_mats > redirect\n" unless (@ARGV);

($list)=@ARGV;
chomp ($list);
open (LIST, "<$list" ) or die "Can't open $list\n";
while ($mat =<LIST>){
    chomp ($mat);
    next unless ($mat);
    $first=1;
    $maphit=0;
    $mis=0;
    open (IN, "<$mat" ) or die "Can't open $mat\n";
    while ($line =<IN>){
	chomp ($line);
	next unless ($line);
	next if ($line=~/\# QIIME/);
	($OTU, @pieces)=split ("\t", $line);
	if ($first){
	    @headers=@pieces;
	    ($mapping)=pop(@pieces);
	    ($lin)=pop(@pieces);
	    $first=();
	} else {
	    ($mapping)=pop(@pieces);
	    ($lin)=pop(@pieces);
	    $sumitup=0;
	    foreach $piece (@pieces){
		$sumitup+=$piece;
	    }
	    if ($mapping eq "NA"){
		$mis+=$sumitup;
	    } elsif ($mapping=~/27F/){
		$maphit+=$sumitup;
	    } else {
		die "Don't recognize $mapping: $line\n";
	    }
	}
    }
    print "$mat\t$maphit\t$mis\n";
    close (IN);
}
close (LIST);
