#! /usr/bin/perl -w

die "Usage: <list of files> > redirect\n" unless (@ARGV);
($file) = (@ARGV);
chomp ($file);

open (IN, "<$file" ) or die "Can't open $file\n";
while ($line =<IN>){
    chomp ($line);
    open (IN2, "<$line" ) or die "Can't open $line\n";
    $first=1;
    while ($line2=<IN2>){
	chomp ($line2);
	($OTU, @pieces)= split ("\t", $line2);
	if ($first){
	    #get headers
	    (@headers) = @pieces;
	    foreach $header (@headers){
		$totallib{$header}++;
	    }
	    $first=();
	} else {
	    $j = @pieces;
	    $i=0;
	    until ($i >=$j){
		$hash{$OTU}{$headers[$i]}=$pieces[$i];
		$i++;
	    }
	}
    }
    close (IN2);
}

close (IN);
print "LIB";
foreach $lib (sort keys %totallib){
    print "\t$lib";
}
print "\n";

foreach $OTU (sort keys %hash){
    print "$OTU";
    foreach $lib (sort keys %totallib){
	if ($hash{$OTU}{$lib}){
	    print "\t$hash{$OTU}{$lib}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}
