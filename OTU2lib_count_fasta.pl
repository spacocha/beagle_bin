#! /usr/bin/perl -w
#
#

	die "Use this program to take the tab file and make a matrix with the library counts
Usage: data_file OTUcol libcol > Redirect\n" unless (@ARGV);
	($file2, $OTUcol, $libcol) = (@ARGV);
	die "Please follow command line args\n" unless ($file2);
chomp ($file2);
chomp ($OTUcol);
chomp ($libcol);
($OTUcolm1)=$OTUcol-1;
($libcolm1)=$libcol-1;

open (IN, "<${file2}") or die "Can't open ${file2}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    #remove if it was removed at any step of the process
    next if ($line=~/remove/);
    (@pieces) = split ("\t", $line);
    ($OTU)=$pieces[$OTUcolm1];
    ($lib)=$pieces[$libcolm1];
    next unless ($OTU && $lib);
    $OTUhash{$OTU}{$lib}++;
    $alllib{$lib}++;
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

