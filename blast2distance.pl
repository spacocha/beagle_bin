#! /usr/bin/perl -w
#
#

	die "Usage: rdp fastacmd.fa .trans output\n" unless (@ARGV);
	($file2, $file3, $file4, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file2);
chomp ($file3);
chomp ($file4);
chomp ($output);

$/=">";

print "Opening fastacmd.fa file: $file3\n";
open (IN, "<$file3") or die "Can't open $file3\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs)=split ("\n", $line);
    ($gino)=$info=~/gi\|([0-9]+)\:/;
    next unless ($gino);
    ($sequence)=join ("", @seqs);
    $longnamehash{$gino}=$info;
    $seqhash{$gino}=$sequence;
}
close (IN);


print "Opening rdp $file2\n";
open (IN, "<$file2") or die "Can't open $file2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs)=split ("\n", $line);
    ($gino)=$info=~/gi\|([0-9]+)\:/;
    next unless ($gino);
    ($sequence)=join ("", @seqs);
    $hashindex=1;
    $i=0;
    $j=1;
    (@pieces)=split(";", $sequence);
    $k=@pieces;
    until ($j>=$k){
	if ($pieces[$j]>0.5){
	    $rdphash{$gino}{$j}=$pieces[$i];
	} else {
	    $rdphash{$gino}{$j}="Unknown";
	}
	$i+=2;
	$j+=2;
    }
}
close (IN);


$/="\n";
print "Opening $file4\n";
open (IN, "<$file4") or die "Can't open $file4\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, $gi, $per, $mat, $mis, $gap, $qstart, $qend, $sstart, $send, $exp, $score)=split ("\t", $line);
    #now I want to get the whole seqeunce, but check if it's very long
    if ($seqhash{$gi}){
	#Make a hash of all the good ones for each OTU
	if ($per ==100 && $mat == $qend && $mis ==0 && $gap == 0){
	    #the gi has the exact match to the OTU (only deal with exact matches)
	    $OTU2gihash{$OTU}{$gi}="identical";
	}
    } else {
	$missing{$OTU}++;
    }
}
close (IN);

open (OUT2, ">${output}_results") or die "Can't open ${output}_results\n";
foreach $OTU (sort keys %OTU2gihash){
#    print OTU2 "$OTU\t";
#    next unless ($OTU eq "ID0000004P" || $OTU eq "ID0000010P");
    open (OUT, ">${output}_clustal") or die "Can't open ${output}_clustal\n";
    %rdpout=();
    foreach $gi (sort keys %{$OTU2gihash{$OTU}}){
	#print out for clustal
	print OUT ">$gi\n$seqhash{$gi}\n";
	foreach $i (sort keys %{$rdphash{$gi}}){
#	    print "GI:$gi I:$i RDP:$rdphash{$gi}{$i}\n";
	    $rdpout{$i}{$rdphash{$gi}{$i}}++;
	}
    }
    close (OUT);
    print "running clustal\n";
    system ("/opt/Bio/clustalw/bin/clustalw2 -INFILE=${output}_clustal -ALIGN");
    system ("/opt/Bio/clustalw/bin/clustalw2 -INFILE=${output}_clustal.aln -TREE -outputtree=dist -OUTFILE=${output}_clustal.dst");
    $first=1;
    %datahash=();
    $first=1;
    $dstgi=();
    open (IN, "<${output}_clustal.dst") or die "Can't open ${output}_clustal.dst\n";
    while ($line=<IN>){
	chomp ($line);
	next unless ($line);
	(@pieces) = split (" ", $line);
	if ($first){
	    $totalno=$line;
	    $totalno=~s/ //g;
	    $first=();
	    $gotten=0;
	    $gicount=0;
	} else {
	        #have you already started with a gi?
	    if ($dstgi){
		#is this the end of the file?
		if ($gotten >= $totalno){
		    #start over
		    ($dstgi)=shift(@pieces);
		    $gicount++;
		    $gicounthash{$gicount}=$dstgi;
		    $gotten=0;
		    foreach $piece (@pieces){
			$gotten++;
			$datahash{$gicount}{$gotten}=$piece;
		    }
		} else {
		    foreach $piece (@pieces){
			$gotten++;
			$datahash{$gicount}{$gotten}=$piece;
		    }
		}
	    } else {
		#first get the gi
		($dstgi)=shift(@pieces);
		$gicount++;
		$gicounthash{$gicount}=$dstgi;
		#die"GI First:$gi\n";
		foreach $piece (@pieces){
		    $gotten++;
		    $datahash{$gicount}{$gotten}=$piece;
		}
	    }
	}
	
    }
    close (IN);
    #now get the average distance
    $running=0;
    $total=0;
    %highlow=();
    foreach $gino (sort keys %datahash){
	($gi)=$gicounthash{$gino};
	foreach $othergino (sort keys %{$datahash{$gino}}){
	    ($othergi) = $gicounthash{$othergino};
	    next if ($gi eq $othergi);
	    $running+=$datahash{$gino}{$othergino};
	    $total++;
	    $highlow{$datahash{$gino}{$othergino}}++;
	    print "$datahash{$gino}{$othergino}\n";
	}
    }
    %hash1=%highlow;
    ($std)=stdev();
    $average=$running/$total if ($total);
    $countotal=0;
    foreach $val (sort {$a <=> $b} keys %highlow){
	$low=$val;
	last;
    }
    foreach $val (sort {$b<=> $a} keys %highlow){
	$high=$val;
	last;
    }
    #what do I want to know about the rdp classifications?
    print OUT2 "$OTU\tAverage dist: $average\tStdev: $std\tHigh: $high\tLow: $low\tMissing: $missing";
    foreach $i (sort {$a <=> $b} keys %rdpout){
	print OUT2 "\tI, $i:";
	$first=1;
	foreach $thing (sort keys %{$rdpout{$i}}){
	    #is there only one thing?
	    if ($first){
		print OUT2 "${thing} ($rdpout{$i}{$thing})";
		$first=();
	    } else {
		print OUT2 ",${thing} ($rdpout{$i}{$thing})";
	    }
	}
    }
    print OUT2 "\n";
}

close (OUT2);
sub stdev {
        
        #input a hash with the values to be averaged and stdev'd
        #from Biometry Sokal et al (?)

    return $std = 0 if ($total == 0);               #can not find stdev if there are no values
    $sum =0;                                        #blank this value
    $total2=0;
    foreach $value (keys %hash1){                    #find the sum of all values
	$i=0;
	until ($i>=$hash1{$value}){
	    $sum+=$value;
	    $i++;
	    $total2++;
	}
    }

    $average = $sum/$total2;                         #calculate the mean or average
        
    $ysq = 0;                                       #clear values
    $ysum = 0;

    foreach $value (keys %hash1){                    #for each find the square of the difference from the mean
	$i=0;
	until ($i>=$hash1{$value}){
	    $y = $value - $average;
	    $ysq = $y*$y;
	    $ysum+=$ysq;                            #sum all squared values
	    $i++;
	}
    }
        
    $std = sqrt($ysum/($total2 - 1));                #find the square root of the squared sum divided by total -1
    $var=$std**2;
}
