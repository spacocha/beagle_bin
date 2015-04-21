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
	$hash{$mapping}{$mat}=$sumitup;
	$allOTU{$mapping}++;
	$allmat{$mat}++;
    }
    close (IN);
}
close (LIST);

foreach $mapping (sort keys %allOTU){
    print "Mapping";
    foreach $mat (sort keys %allmat){
	print "\t$mat";
    }
    last;
}
print "\n";

foreach $mapping (sort keys %allOTU){
    print "$mapping";
    foreach $mat (sort keys %allmat){
	if ($hash{$mapping}{$mat}){
	    print "\t$hash{$mapping}{$mat}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}
