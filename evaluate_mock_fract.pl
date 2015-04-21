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
	    $matbarhash{$map}++;
	    $mathash{$file1}{$map}=$pieces;
	    $maphash{$file2}{$map}=$truemock;
	    $printedmock{$map}++;
	} else {
	    print "$OTU\t$pieces\t0\n";
	    $matbarhash{$OTU}++;
	    $mathash{$file1}{$OTU}=$pieces;
	    $mathash{$file2}{$OTU}=0;
	}
    }
}
close (IN1);

foreach $mock (sort keys %gothash){
    unless ($printedmock{$mock}){
	$truemock=$frachash{$mock}*$totaltrue;
	print "$mock\t0\t$truemock\n";
    }
}


sub JS_value {
    #pass the two OTUs that you want to compare
    #need to have matbarhash defined with all of the 
    #header values in the library
    #also need mathash defined with the count of each OTU across all libraries

    my ($one);
    my ($two);
    my ($JS1);
    $JS1=0;
    my ($JS2);
    $JS2=0;
    my ($newJS);
    $newJS=0;
    my ($q);
    my ($p);
    my ($header);
    ($one, $two) = @_;
    my ($total1, $total2);
    $total1=0;
    $total2=0;
    #Get the total number of counts per OTU
    foreach $header (sort keys %matbarhash){
	if ($mathash{$one}{$header}){
	    $total1+=$mathash{$one}{$header};
	}
	if ($mathash{$two}{$header}){
	    $total2+=$mathash{$two}{$header};
	}
    }
    
    foreach $header (sort keys %matbarhash){
	#each is defined as the portion of the total amount in the OTU
	if ($mathash{$one}{$header} && $total1){
	    #normalize to the total number of counts per OTU
	    ($p) = $mathash{$one}{$header}/$total1;
	} else {
	    $p=0;
	}
	if ($mathash{$two}{$header} && $total2){
	    ($q) = $mathash{$two}{$header}/$total2;
	} else {
	    $q=0;
	}
	#calculate for p
	if ($p > 0){
	    $sum1=($p+$q)/2;
	    $sum2=$p/$sum1;
	    $sum3=log($sum2)/log(2);
	    $sum4=$p*$sum3;
	    #sum of all JS1s
	    $JS1+=$sum4;
	}
	#calcuate for q
	if ($q > 0){
	    $sum1=($q+$p)/2;
	    $sum2=$q/$sum1;
	    $sum3=(log($sum2))/log(2);
	    $sum4=$q*$sum3;
	    #sum of all JS2s
	    $JS2+=$sum4;
	}
	print LOG "$one\t$p\t$total1\t$mathash{$one}{$header}\t$JS1\t$two\t$q\t$total2\t$mathash{$two}{$header}\t$JS2\n" if ($verbose);
    }
    $newJS=($JS1 + $JS2)/2;
    return ($newJS);
}

