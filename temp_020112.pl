#! /usr/bin/perl -w

die "Usage: true matfile > redirect\n" unless (@ARGV);

($true, $mat)=(@ARGV);
chomp ($mat);
chomp ($true);

open (IN, "<$true" ) or die "Can't open $true\n";
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    $hash{$line}++;
}
close (IN);

open (IN, "<$mat" ) or die "Can't open $mat\n";
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @p)=split ("\t", $line);

    if ($first){
	print "$OTU";
	foreach $part (@p){
	    print "\t$part";
	}
	print "\n";
	$first=();
    } else {
	if ($hash{$OTU}){
	    print "$OTU";
	    foreach $part (@p){
		print "\t$part";
	    }
	    print "\n";
	}
    }
}
close (IN);


