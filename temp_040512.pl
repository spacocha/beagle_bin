#! /usr/bin/perl -w

die "Usage: unfiltered.mat.map filtered.mat.map > redirect\n" unless (@ARGV);

($mat1, $mat2)=(@ARGV);
chomp ($mat1, $mat2);

@headers=();
open (IN, "<$mat1" ) or die "Can't open $mat1\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if (@headers){
	($ref)=pop(@pieces);	
	next if ($ref eq "NA");
	$i=0; 
	$j=@pieces;
	until ($i >=$j){
	    $mat1hash{$ref}{$headers[$i]}+=$pieces[$i];
	    $i++;
	}
    } else {
	(@headers)=@pieces;
    }
}
close (IN);

@headers=();
open (IN, "<$mat2" ) or die "Can't open $mat2\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if (@headers){
	($ref)=pop(@pieces);
	next if ($ref eq "NA");
	next unless (%{$mat1hash{$ref}});
	$i=0;
        $j=@pieces;
        until ($i >=$j){
	    if ($mat1hash{$ref}{$headers[$i]}){
		if ($mat1hash{$ref}{$headers[$i]}){
		    $diff=$mat1hash{$ref}{$headers[$i]} - $pieces[$i];
		    $percent=100*${diff}/$mat1hash{$ref}{$headers[$i]};
		    $percenthash{$ref}{$headers[$i]}=$percent; 
		} else {
		    $percenthash{$ref}{$headers[$i]}=0;
		}
		$allheaders{$headers[$i]}++;
	    }
	    $i++;
        }
    } else {
        (@headers)=@pieces;
    }
}
close (IN);

foreach $OTU (sort keys %percenthash){
    print "OTU";
    foreach $head (sort keys %allheaders){
	print "\t$head";
    }
    print "\n";
    last;
}

foreach $OTU (sort keys %percenthash){
    print "$OTU";
    foreach $head (sort keys %allheaders){
	if ($percenthash{$OTU}{$head}){
	    print "\t$percenthash{$OTU}{$head}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}
