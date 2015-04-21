#! /usr/bin/perl -w
#
#

	die "Usage: mat_file > redirect\n" unless (@ARGV);
	($mat) = (@ARGV);
die "Please follow command line args\n" unless ($mat);
chomp ($mat);

open (IN, "<$mat") or die "Can't open $mat\n";
while ($line=<IN>){
    chomp ($line);
    ($OTU, @abunds) = split ("\t", $line);

    if (@headers){
	$i=0;
	$j=@abunds;
	until ($i>=$j){
	    if ($headers[$i]=~/^.+\.[0-9]{2}$/){
		($corehead)=$headers[$i]=~/^(.+)\.[0-9]{2}$/;
	    } else {
		($corehead)=$headers[$i];
	    }	
	    $hash{$OTU}{$corehead}+=$abunds[$i];
	    $i++;
	}
    } else {
	(@headers)=@abunds;
	foreach $head (@headers){
            if ($head=~/^.+\.[0-9]{2}$/){
                ($corehead)=$head=~/^(.+)\.[0-9]{2}$/;
            } else {
                ($corehead)=$headers[$i];
            }
	    $allheadhash{$corehead}++;
	}
    }
}
close (IN);

foreach$OTU (sort keys%hash){
    print "OTU";
    foreach $head (sort keys %allheadhash){
	print "\t$head";
    }
    print "\n";
    last;
}

foreach $OTU (sort keys %hash){
    print "$OTU";
    foreach $head (sort keys %allheadhash){
	if ($hash{$OTU}{$head}){
	    print "\t$hash{$OTU}{$head}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}
