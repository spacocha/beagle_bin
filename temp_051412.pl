#! /usr/bin/perl -w
#   Edited on 04/02/12 
#
$programname="temp_051012.pl";

	die dieHelp () unless (@ARGV); 

($matfile)=@ARGV;

open (IN, "<$matfile" ) or die "Can't open $matfile\n";
@headers=();
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/QIIME/);
    ($OTU, @libs) =split ("\t", $line);
    if (@headers){
	$i=0;
	$j=@libs;
	until ($i >= $j){
	    $hash{$headers[$i]}{$OTU}=$libs[$i];
	    $totalhash{$headers[$i]}+=$libs[$i];
	    $i++;
	}
    } else {
	(@headers)=(@libs);
    }
}
close (IN);

foreach $head (sort keys %hash){
    foreach $ohead (sort keys %hash){
	next if ($head eq $ohead);
	($JSvalue)=JS_value($head, $ohead);
	print "$head\t$ohead\t$JSvalue\n";
    }
}
############
#subroutines
############

sub dieHelp {

die "Usage: perl $programname dist > redirect\n";
}

sub JS_value {
    #pass the two OTUs that you want to compare
    #need to have matbarhash defined with all of the 
    #header values in the library
    #also need mathash defined with the count of each OTU across all libraries

    my ($JS1);
    $JS1=0;
    my ($JS2);
    $JS2=0;
    my ($newJS);
    $newJS=0;
    my ($q);
    my ($p);
    my ($OTU);
    ($one, $two)=@_;
    foreach $OTU (sort keys %{$hash{$one}}){
	if ($hash{$one}{$OTU} && $totalhash{$one}){
	    #make it a percent
	    ($p) = $hash{$one}{$OTU}/$totalhash{$one};
	} else {
	    $p=0;
	}
	if ($hash{$two}{$OTU} && $totalhash{$two}){
	    #it is already a percent
	    ($q) = $hash{$two}{$OTU}/$totalhash{$two};
	} else {
	    $q=0;
	}
	print "$OTU\t$one\t$p\t$two\t$q";
	if ($p > 0){
	    #first make the KL of x,(x+y)/2
	    $sum1=($p+$q)/2;
	    $sum2=$p/$sum1;
	    $sum3=log($sum2)/log(2);
	    $sum4=$p*$sum3;
	    $JS1+=$sum4;
	}
	if ($q > 0){
	    $sum1=($q + $p)/2;
	    $sum2=$q/$sum1;
	    $sum3=log($sum2)/log(2);
	    $sum4=$q*$sum3;
	    $JS1+=$sum4;
	}
	print "\t$JS1\t$JS2\n";
    }
    $newJS=($JS1 + $JS2)/2;
    print "$newJS\n";
    return ($newJS);
}

