#! /usr/bin/perl -w
#
#

	die "Use this program to take the tab file and make a matrix with the library counts
Usage: barfile data_file name_col lib_column OTU_column> Redirect\n" unless (@ARGV);
	($file1, $file2, $namecol, $libcol, $OTUcol) = (@ARGV);

	die "Please follow command line args\n" unless ($libcol);
chomp ($file1);
chomp ($file2);
chomp ($namecol);
chomp ($OTUcol);
chomp ($libcol);
$namecolm1= $namecol-1;
$libcolm1=$libcol-1;
$OTUcolm1=$OTUcol-1;

open (IN, "<${file1}") or die "Can't open ${file1}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($lib, $bar)=split ("\t", $line);
    $libnamehash{$lib}=$bar;
}
close (IN);

open (IN, "<${file2}") or die "Can't open ${file2}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces) = split ("\t", $line);
    $name=$pieces[$namecolm1];
    $OTU=$pieces[$OTUcolm1];
    $lib=$pieces[$libcolm1];
    $OTUhash{$OTU}{$lib}++;
    $alllib{$lib}++;
 }
close (IN);

foreach $OTU (sort keys%OTUhash){
    print "OTU";
    foreach $lib (sort keys %alllib){
	print "\t${lib}_${libnamehash{$lib}}";
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

