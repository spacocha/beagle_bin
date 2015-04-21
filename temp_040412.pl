#! /usr/bin/perl -w

die "Usage: ref.fa unfiltereed.fa unfiltered.mat  filtered.fa filtered.mat > redirect\n" unless (@ARGV);

($ref, $fa1, $mat1, $fa2, $mat2)=(@ARGV);
chomp ($ref, $fa1, $fa2, $mat1, $mat2);

$/=">";
open (IN, "<$ref" ) or die "Can't open $ref\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\n", $line);
    ($seq)=join ("", @pieces);
    $refhash{$seq}=$OTU;
}
close (IN);

open (IN, "<$fa1" ) or die "Can't open $fa1\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\n", $line);
    ($seq)=join("", @pieces);
    if ($refhash{$seq}){
	$seq1hash{$OTU}=$refhash{$seq};
    }
}
close (IN);

open (IN, "<$fa2" ) or die "Can't open $fa2\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\n", $line);
    ($seq)=join("", @pieces);
    if ($refhash{$seq}){
	$seq2hash{$OTU}=$refhash{$seq};
    }
}
close (IN);

$/="\n";
@headers=();
open (IN, "<$mat1" ) or die "Can't open $mat1\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if (@headers){
	next unless ($seq1hash{$OTU});
	$ref=$seq1hash{$OTU};
	$i=0; 
	$j=@pieces;
	until ($i >=$j){
	    $mat1hash{$ref}{$headers[$i]}=$pieces[$i];
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
	next unless ($seq2hash{$OTU});
	$ref=$seq2hash{$OTU};
	next unless (%{$mat1hash{$ref}});
	$i=0;
        $j=@pieces;
        until ($i >=$j){
	    if ($mat1hash{$ref}{$headers[$i]}){
		$diff=$mat1hash{$ref}{$headers[$i]} - $pieces[$i];
		if ($mat1hash{$ref}{$headers[$i]}){
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
