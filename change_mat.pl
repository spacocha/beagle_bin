#! /usr/bin/perl -w

die "Usage: change mat > redirect\n" unless (@ARGV);
($change, $mat) = (@ARGV);
chomp ($mat);
chomp ($change);

open (IN, "<$change" ) or die "Can't open $change\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    next unless ($line=~/Changefrom,.+,.+,Changeto/);
    ($from, $to)=$line=~/Changefrom,(.+),(.+),Changeto/;
    $changehash{$from}=$to;
}
close (IN);

open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if (@headers){
	unless ($changehash{$OTU}){
	    print "$OTU";
	    foreach $piece (@pieces){
		print "\t$piece";
	    }
	    print "\n";
	}
    } else {
	(@headers)=@pieces;
	print "$OTU";
	foreach $header (@headers){
	    print "\t$header";
	}
	print "\n";
    }
}
close (IN);
