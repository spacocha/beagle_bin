#!/usr/bin/perl

# Correlation
# Didier Gonze
# Updated: 28/4/2004

##########################################################################################
die "Usage: Input_file > output\n" unless (@ARGV);
($infile) = (@ARGV);
chomp ($infile);


&ReadData;



##########################################################################################
### Read the data and fill the data vector

sub ReadData {

    my $i=0;
    my $badlines=0;

    open (inf, "<$infile") or die "Can't open $infile\n";
    $one=();
    while ($line=<inf>){
	chomp $line;
	if ($one){
	    ($sample, @distr)=split (/\t/,$line);
	    $i=0;
	    $totalvalue=0;
	    foreach $value (@distr){
		$totalvalue+=$value;
		$hash{$sample}{$i}=$value;
		$i++;
	    }
	    $tvhash{$sample}=$totalvalue;
	} else {
	    $one++;
	}
    }
    close (inf);
    foreach $sample (sort keys %hash){
	next unless ($tvhash{$sample}>1000);
	foreach $osample (sort keys %hash){
	    next unless ($tvhash{$osample}>1000);
	    next if ($sample eq $osample);
	    next if ($done{$sample}{$osample} || $done{$osample}{$sample});
	    $done{$sample}{$osample}++;
	    $nbdata=0;
	    $badlines =0;
	    foreach $i (sort keys %{$hash{$sample}}){
		if ($hash{$sample}{$i} =~ /\d+/ && $hash{$osample}{$i} =~ /\d+/){
		    $x[1][$i]=$hash{$sample}{$i};
		    $x[2][$i]=$hash{$osample}{$i};
		    $nbdata++;
		} else{
		    $badlines++;
		}
	    }
	    $correl = 0;
	    ($correl) = Correlation() unless ($badlines);
	    print "${sample}\t${osample}\t$correl\n" unless ($badlines);
	}
    }

}  # End of ReadData


##########################################################################################
### Correlation

sub Correlation {

    $mean[1]=&Mean(1);
    $mean[2]=&Mean(2);

    if ($verbo==1) {
	$xmean1=sprintf("%.3f",$mean[1]);
	$xmean2=sprintf("%.3f",$mean[2]);
	print "Mean($col1) = $xmean1\n";
	print "Mean($col2) = $xmean2\n";
    }

    $ssxx=&SS(1,1);
    $ssyy=&SS(2,2);
    $ssxy=&SS(1,2);

    if ($verbo==1) {
	$xssxx=sprintf("%.3f",$ssxx);
	$xssyy=sprintf("%.3f",$ssyy);
	$xssxy=sprintf("%.3f",$ssxy);
	print "SS($col1)= $xssxx\n";
	print "SS($col2) = $xssyy\n";
	print "SS($col1,$col2) = $xssxy\n";
    }

    $correl=&Correl($ssxx,$ssyy,$ssxy);

    $xcorrel=sprintf("%.4f",$correl);

    return $xcorrel;

}  # End of Correlation


##########################################################################################
### Mean

sub Mean {

    my ($a)=@_;
    my ($i,$sum)=(0,0);

    for ($i=1;$i<=$nbdata;$i++){
	$sum=$sum+$x[$a][$i];
    }
    if ($nbdata ==0){
	$mu=0;
    } else {
	$mu=$sum/$nbdata;
    }
    return $mu;

}

##########################################################################################
### SS = sum of squared deviations to the mean

sub SS {

    my ($a,$b)=@_;
    my ($i,$sum)=(0,0);

    for ($i=1;$i<=$nbdata;$i++){
	$sum=$sum+($x[$a][$i]-$mean[$a])*($x[$b][$i]-$mean[$b]);
    }

    return $sum;

}

##########################################################################################
### Correlation

sub Correl {

    my($ssxx,$ssyy,$ssxy)=@_;

    return ("NA") if ($ssxy==0);
    $sign=$ssxy/abs($ssxy);

    $correl=$sign*sqrt($ssxy*$ssxy/($ssxx*$ssyy));

    return $correl;

}
