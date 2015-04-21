#! /usr/bin/perl -w

die "Usage: tab fasta output\n" unless (@ARGV);
($tab, $fasta, $output) = (@ARGV);
chomp ($fasta, $tab, $output);

open (IN1, "<$tab" ) or die "Can't open $tab\n";
while ($line1 =<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($OTU, @pieces)=split("\t", $line1);
    if (@headers){
	($lin)=pop(@pieces);
	($map)=pop(@pieces);
	$linhash{$OTU}=$lin;
	$maphash{$OTU}=$map;
	$j=@pieces;
	$i=0;
	until ($i>=$j){
	    if ($headers[$i]=~/^305/){
		#manually found the samples that should not be included- exclude them here
		unless ($headers[$i] eq "305T17" || $headers[$i] eq "305T12" || $headers[$i] eq "305T08" || $headers[$i] eq "305T07"){
		    if ($OTU eq "TotalCounts"){
			$totalcounts{$headers[$i]}=$pieces[$i];
		    } else {
			#only keep the groundwater samples
			$hash{$headers[$i]}{$OTU}=$pieces[$i];
			$allheaders{$headers[$i]}++;
			$allotuhash{$OTU}++ if ($pieces[$i]);
		    }
		}
	    }
	    $i++;
	}
    } else {
	($lin)=pop(@pieces);
	(@headers)=@pieces;
    }	      
}
close (IN1);

open (OUT1, ">${output}.fa") or die "Can't open ${output}.fa\n";

open (IN1, "<$fasta" ) or die "Can't open $fasta\n";
$/=">";
while ($line1 =<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($header, @sequences)=split ("\n", $line1);

    ($seq)=join("", @sequences);
    $seq=~s/\n//g;
    if ($allotuhash{$header}){
	print OUT1 ">$header\n$seq\n";
    }
}

close (IN1);
close (OUT1);

foreach $header (sort keys %allheaders){
    print "$header\n";
    open ($header, ">${output}.${header}.tab") or die "Can't open ${output}.${header}.tab\n";
    foreach $OTU (sort {$hash{$header}{$b} <=> $hash{$header}{$a}} keys %{$hash{$header}}){
	print "$OTU $hash{$header}{$OTU}\n";
	print $header "$OTU\t$hash{$header}{$OTU}\n" if ($hash{$header}{$OTU});
    }
    close ($header);
}
