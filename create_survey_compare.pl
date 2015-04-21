#! /usr/bin/perl
#
#

	die "Usage: real_mat.map fractions total_true_counts > redirect\n" unless (@ARGV);
	($file1, $file2, $totaltrue) = (@ARGV);

	die "Please follow command line args\n" unless ($totaltrue);
chomp ($file1);
chomp ($file2);
chomp ($totaltrue);


open (IN2, "<$file2") or die "Can't open $file2\n";
$first=1;
while ($line2=<IN2>){
    chomp ($line2);
    next unless ($line2);
    ($map, $fraction)=split("\t", $line2);
    if ($first){
	$first=0;
    } else {
	$frachash{$map}=$fraction;
	$gothash{$map}++;
    }
}
close (IN2);


open (IN1, "<$file1") or die "Can't open $file1\n";
$first=1;
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($OTU, $total, $pieces, $map)=split("\t", $line1);
    if ($first){
	#headers
	$first=0;
	print "$OTU\t$pieces\t$file2\n";
    } else {
	if ($gothash{$map}){
	    $truemock=$frachash{$map}*$totaltrue;
	    print "$map\t$pieces\t$truemock\n";
	} else {
	    print "$OTU\t$pieces\t0\n";
	}
    }
}
close (IN1);

