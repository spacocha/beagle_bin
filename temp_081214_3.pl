#! /usr/bin/perl -w

die "Usage: trans Ground Reactors > redirect\n" unless (@ARGV);
($trans, $Gmat, $Rmat) = (@ARGV);
chomp ($trans, $Gmat, $Rmat);

$verbose=0;
open (IN, "<${trans}") or die "Can't open ${trans}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($well, $R1, $R2, $R3)=split ("\t", $line);
    $wellhash{$well}++;
    $R1hash{$R1}=$R2;
    $R2hash{$R2}=$R3;
    $R3hash{$R3}=$R1;
}
close (IN);


open (IN, "<$Gmat" ) or die "Can't open $Gmat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @counts)=split ("\t", $line);
    next if ($OTU eq "Total");
    if (@headers){
	$i=0;
	$j=@counts;
	until ($i >=$j){
	    $totalmathash{$headers[$i]}{$OTU}=$counts[$i];
	    $totalmatbarhash{$OTU}++;
	    $i++;
	}
    } else {
	(@headers)=@counts;
    }
	
}

close (IN);

@headers=();

open (IN, "<$Rmat" ) or die "Can't open $Rmat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @counts)=split ("\t", $line);
    next if ($OTU eq "Total");
    if (@headers){
        $i=0;
        $j=@counts;
        until ($i >=$j){
            $totalmathash{$headers[$i]}{$OTU}=$counts[$i];
	    $totalmatbarhash{$OTU}++;
            $i++;
        }
    } else {
        (@headers)=@counts;
    }
}
close (IN);

foreach $reactor (sort keys %R1hash){
    %mathash=();
    %matbarhash=();
    foreach $OTU (sort keys %totalmatbarhash){
	if ($totalmathash{$reactor}{$OTU} || $totalmathash{$R1hash{$reactor}}{$OTU}){
	    $mathash{$reactor}{$OTU}=$totalmathash{$reactor}{$OTU};
	    $mathash{$R1hash{$reactor}}{$OTU}=$totalmathash{$R1hash{$reactor}}{$OTU};
	    $matbarhash{$OTU}++;
	}
    }
    ($JSD)=JS_value($reactor, $R1hash{$reactor});
    print "$reactor\t$R1hash{$reactor}\t$JSD\n";
}
foreach $reactor (sort keys %R2hash){
    %mathash=();
    %matbarhash=();
    foreach $OTU (sort keys %totalmatbarhash){
	if ($totalmathash{$reactor}{$OTU} || $totalmathash{$R2hash{$reactor}}{$OTU}){
            $mathash{$reactor}{$OTU}=$totalmathash{$reactor}{$OTU};
            $mathash{$R2hash{$reactor}}{$OTU}=$totalmathash{$R2hash{$reactor}}{$OTU};
            $matbarhash{$OTU}++;
        }
    }
    ($JSD)=JS_value($reactor, $R2hash{$reactor});
    print "$reactor\t$R2hash{$reactor}\t$JSD\n";
}

foreach $reactor (sort keys %R3hash){
    %mathash=();
    %matbarhash=();
    foreach $OTU (sort keys %totalmatbarhash){
	if ($totalmathash{$reactor}{$OTU} || $totalmathash{$R3hash{$reactor}}{$OTU}){
            $mathash{$reactor}{$OTU}=$totalmathash{$reactor}{$OTU};
            $mathash{$R3hash{$reactor}}{$OTU}=$totalmathash{$R3hash{$reactor}}{$OTU};
            $matbarhash{$OTU}++;
        }
    }
    ($JSD)=JS_value($reactor, $R3hash{$reactor});
    print "$reactor\t$R3hash{$reactor}\t$JSD\n";
}

###SUBROUTINES


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
	print "$one\t$p\t$total1\t$mathash{$one}{$header}\t$JS1\t$two\t$q\t$total2\t$mathash{$two}{$header}\t$JS2\n" if ($verbose);
    }
    $newJS=($JS1 + $JS2)/2;
    return ($newJS);
}

sub findcorrel {
    #%matbarhash must be defined and contain the keys of all possible libraries
    #%mathash must be defined and contain the values of each OTU across all libraries
    #R must be loaded and running
    my ($one, $two);
    ($one, $two) = @_;
    my ($string);
    $string=();
    my ($totalnolib);
    $totalnolib=();
    my ($correl);
    foreach $bar (sort keys %matbarhash){
	#don't print, but pass something to R
	$mathash{$two}{$bar} = 0 unless ($mathash{$two}{$bar});
	$mathash{$one}{$bar} =0 unless ($mathash{$one}{$bar});
	if ($mathash{$two}{$bar} || $mathash{$one}{$bar}){
	    if ($string){
		$string="$string"."$mathash{$two}{$bar}\t$mathash{$one}{$bar}\n";
	    } else {
		$string="$mathash{$two}{$bar}\t$mathash{$one}{$bar}\n";
	    }
	    $totalnolib++ if ($mathash{$two}{$bar} || $mathash{$one}{$bar});
	}
    }
    if ($totalnolib ==1){
	$correl="NA";
    } else {
	system ("rm ${Rfile}.corv\n") if (-e "${Rfile}.corv");
	#run chisq and fishers
	open (INPUT, ">${Rfile}.in") or die "Can't open ${Rfile}.in\n";
	print INPUT "$string\n";
	close (INPUT);
	open (FIS, ">${Rfile}.cor") or die "Can't open ${Rfile}.cor\n";
	print FIS "x <- read.table(\"${Rfile}.in\", header = FALSE)                                                                                        
a<-x[1:${totalnolib},1]                                                                                               
b<-x[1:${totalnolib},2]                                                                                                                                                         
j<-cor(a,b)                                                                               
print(j)
write.table(j,file=\"${Rfile}.corv\",sep=\"\t\",row.names=FALSE,col.names=FALSE)\n";
	close (FIS);

	system ("R --slave --vanilla --silent < ${Rfile}.cor >> ${Rfile}.err");

	if (-e "${Rfile}.corv"){
	    $correl=();
	    my ($Rline);
	    open (RES, "<${Rfile}.corv") or die "Can't open ${Rfile}.corv\n";
	    while ($Rline=<RES>){
		chomp ($Rline);
		next unless ($Rline);
		($correl)=$Rline=~/^(.+)$/;
	    }
	    close (RES);
	} else {
	    die "${Rfile}.corv not available\n";
	}
    }
    return ($correl);

}

