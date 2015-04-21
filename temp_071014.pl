#! /usr/bin/perl -w

die "Usage: split_libs> redirect\n" unless (@ARGV);
($merge) = (@ARGV);
chomp ($merge);

open (IN, "<$merge" ) or die "Can't open $merge\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($bar, $lib)=split ("\t", $line);
    ($newbar)=revcomp($bar);
    print "$newbar\t$lib\n";
}

close (IN);




############
#subroutines of very common use
############

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

sub fastq_mat{

    %qualhash=("B", "2", "C", "3", "D", "4", "E", "5", "F", "6", "G", "7", "H", "8", "I", "9", "J", "10", "K", "11", "L", "12", "M", "13", "N", "14", "O", "15", "P", "16", "Q", "17", "R", "18", "S", "19", "T", "20", "U", "21", "V", "22", "W", "23", "X", "24", "Y", "25", "Z", "26", "[", "27", "\\", "28", "]", "29", "^", "30", "_", "31", "`", "32", "a", "33", "b", "34", "c", "35", "d", "36", "e", "37", "f", "38", "g", "39", "h", "40", "i", "41");

}

sub stdev {
        
        #input a hash with the values to be averaged and stdev'd
        #from Biometry Sokal et al (?)
    #pass %hash with number (1,2,3) as keys and values to be checked as values
    my $total;
    my $std;
    my $sum;
    my $value;
    my $average;
    my $ysq;
    my $ysum;
    my $y;

    $sum =0;                                        #blank this value

    foreach $position (sort {$a <=> $b} keys %qualvalues){                    #find the sum of all values
	$sum=0;
	foreach $number (keys %{$qualvalues{$position}}){
	    #each quality score is stored as the number of 10's (for example) at position 12
	    #so instead of summing up each, just multiply by the value and the number of time that value was seen
	    $add=$qualvalues{$position}{$number}*$number;
	    $sum+=$add;
	}

	$average = $sum/$totalbases{$position};                         #calculate the mean or average
        
	$ysq = 0;                                       #clear values
	$ysum = 0;
	
	foreach $value (keys %{$qualvalues{$position}}){                    #for each find the square of the difference from the mean
	    $y = $value - $average;
	    $ysq = $y*$y;
	    $mysq = $ysq*$qualvalues{$position}{$value};
	    $ysum+=$mysq;                            #sum all squared values
	}
        
	$std = sqrt($ysum/($totalbases{$position} - 1));                #find the square root of the squared sum divided by total -1
	print "$position\t$average\t$std\n";
    }

}

sub revcomp{
    my ($rc_seq);
    (${rc_seq}) = @_;
    (@pieces) = split ("", $rc_seq);
    #make reverse complement
    %revcomphash=(
	"A" => "T", 
	"T" => "A", 
	"U" => "A",
	"G" => "C",
	"C" => "G",
	"Y" => "R",
	"R" => "Y",
	"S" => "S",
	"W" => "W",
	"K" => "M",
	"M" => "K",
	"B" => "V",
	"D" => "H",
	"H" => "D",
	"V" => "B",
	"N" => "N",
	"a" => "t",
	"t" => "a",
	"u" => "a",
	"g" => "c",
	"c" => "g",
	"y" => "r",
	"r" => "y",
	"s" => "s",
	"w" => "w",
	"k" => "m",
	"m" => "k",
	"b" => "v",
	"d" => "h",
	"h" => "d",
	"v" => "b",
	"n" => "n"
	);
    
    $j = @pieces;
    $j-=1;
    $seq = ();
    until ($j < 0){
	if ($pieces[$j]){
	    if ($revcomphash{$pieces[$j]}){
		if ($seq){
		    $seq = "$seq". "$revcomphash{$pieces[$j]}";
		} else {
		    $seq = "$revcomphash{$pieces[$j]}";
		}
	    } else {
		die "No revcomp base for $pieces[$j] $revcomphash{$pieces[$j]}\n";
	    }
	} else {
	    die "NO j $j\n";
	}
	$j--;
    }
    return ($seq);
}

1;
