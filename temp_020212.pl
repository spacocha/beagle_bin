#! /usr/bin/perl -w

die "Usage: tax  mat > redirect\n" unless (@ARGV);

($tax,  $mat)=(@ARGV);
chomp ($mat);
chomp ($tax);

open (IN, "<$tax" ) or die "Can't open $tax\n";
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, $taxon)=split ("\t", $line);
    $transhash{$OTU}=$taxon;
}
close (IN);

open (IN, "<$mat" ) or die "Can't open $mat\n";
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @p)=split ("\t", $line);
    ($trans)=pop(@p);
    if ($first){
	#
	$first=();
	print "$OTU";
	foreach $part (@p){
	    print "\t$part";
	}
	print "\tLin\n";
    } else {
	if ($transhash{$trans}){
	    print "$OTU";
	    foreach $part (@p){
		print "\t$part";
	    }
	    print "\t$transhash{$trans}\n";
	} else {
	    die "No trans $trans\n";
	}
    }
}
close (IN);


