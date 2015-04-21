#! /usr/bin/perl -w

die "Usage: prepared > redirect\n" unless (@ARGV);
($file) = (@ARGV);
chomp ($file);

open (IN, "<${file}") or die "Can't open $file\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    if ($header1 && $header2){
	($OTU, $val1, $val2)= split ("\t", $line);
	$matbarhash{$OTU}++;
	$mathash{$header1}{$OTU}=$val1;
	$mathash{$header2}{$OTU}=$val2;
    } else {
	($header0, $header1, $header2)=split("\t", $line);
    }
    
}

$one=$header1;
$two=$header2;
close (IN);
($returnedJSD)=return_JSD($header1, $header2);
print "$returnedJSD\n";

sub return_JSD{
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
    print "$one\t$p\t$total1\t$mathash{$one}{$header}\t$JS1\t$two\t$q\t$total2\t$mathash{$two}{$header}\t$JS2\n" if ($verbose);
}
$newJS=($JS1 + $JS2)/2;
return ($newJS);
}
