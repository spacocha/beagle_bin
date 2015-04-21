#! /usr/bin/perl -w
#   Edited on 04/02/12 
#
$programname="temp_051112.pl";

	die dieHelp () unless (@ARGV); 

($truefile, $matfile, $colno)=@ARGV;
chomp ($truefile, $matfile, $colno);
$colm1=$colno-2;

open (IN, "<$truefile" ) or die "Can't open $truefile\n";
@headers=();
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, $lib) =split ("\t", $line);
    if ($first){
	$first=();
    } else {
	$hash{$truefile}{$OTU}=$lib;
	$total{$OTU}++;
    }
}
close (IN);

open (IN, "<$matfile" ) or die "Can't open $matfile\n";
@headers=();
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/QIIME/);
    ($OTU, @libs) =split ("\t", $line);
    if (@headers){
	($map)=pop (@libs);
	if ($map=~/27F/){
	    $hash{$matfile}{$map}=$libs[$colm1];
	    $total{$map}++;
	} else {
	    $hash{$matfile}{$OTU}=$libs[$colm1];
	    $total{$OTU}++;
	}
    } else {
	(@headers)=(@libs);
    }
}
close (IN);
print "file";
foreach $file (sort keys %hash){
    print "\t$file";
}
print "\n";

    foreach $OTU (sort keys %total){
	$counts=0;
	foreach $file (sort keys %hash){
	    if ($hash{$file}{$OTU}){
		$counts++;
	    }
	}
	if ($counts){
	    print "$OTU";
	    foreach $file (sort keys %hash){
		if ($hash{$file}{$OTU}){
		    print "\t$hash{$file}{$OTU}";
		} else {
		    print "\t0";
		}
	    }
	    print "\n";
	}
}

sub dieHelp {

    die "Usage: perl $programname true_dist compare_matrix libcol > redirect\n";
}
