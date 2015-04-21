#! /usr/bin/perl -w
#
#

	die "Use this program to make a matrix out of trans and mapping files
Usage: trans mapping > Redirect\n" unless (@ARGV);
	($file1, $mapping) = (@ARGV);
	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
chomp ($mapping);

open (IN, "<${mapping}") or die "Can't open ${mapping}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/\#SampleID/);
    ($lib, $seq)=split ("\t", $line);
    $libhash{$seq}=$lib;
}
close (IN);

open (IN, "<${file1}") or die "Can't open ${file1}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    #remove if it was removed at any step of the process
    next if ($line=~/remove/);
    ($name, $OTU)=split ("\t", $line);
    if ($name=~/\#[A-z]+\/[0-9]/){
	($lib)=$name=~/\#([A-z]+)\/[0-9]/;
	if ($libhash{$lib}){
	    $alllib{$libhash{$lib}}++;
	    $OTUhash{$OTU}{$libhash{$lib}}++;
	}
    } else {
	die "Don't recognize the lib in the name $name\n";
    }
}
close (IN);

foreach $OTU (sort keys%OTUhash){
    print "OTU";
    foreach $lib (sort keys %alllib){
	print "\t$lib";
    }
    print "\n";
    last;
}

foreach $OTU (sort keys %OTUhash){
    print "$OTU";
    foreach $lib (sort keys %alllib){
	if ($OTUhash{$OTU}{$lib}){
	    print "\t$OTUhash{$OTU}{$lib}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}
