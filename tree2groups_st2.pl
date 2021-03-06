#! /usr/bin/perl -w

die "Usage: mat fasta groups\n" unless (@ARGV);
($mat, $fasta, $groups) = (@ARGV);
chomp ($fasta);
chomp($mat);
chomp ($groups);

#print "Opening groups\n";
open (IN, "<$groups" ) or die "Can't open $groups\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($num,$OTU)=split (",", $line);
    $grouphash{$OTU}=$num;
    $grouptotal{$group}++;
}

close (IN);
#print "Opening fa\n";
$/=">";
open (IN, "<$fasta" ) or die "Can't open $fasta\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($newline, $seq)=split ("\n", $line);
    $seqhash{$newline}=$seq;
}
close (IN);
#print "Summing from mat\n";
$/="\n";
$first=1;
open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if ($first){
	(@headers)=@pieces;
	$first=0;
    } else {
	$total=0;
	foreach $piece (@pieces){
	    $total+=$piece;
	}
	$OTUcount{$OTU}=$total;
	#does it have a seq and group
	if ($seqhash{$OTU} && $grouphash{$OTU}){
	    $totalhash{$grouphash{$OTU}}+=$total;
	    #ok
	    $seq=$seqhash{$OTU};
	    $group=$grouphash{$OTU};
	    (@seqpiece)=split ("", $seq);
	    $i=0;
	    $j=@seqpiece;
	    until ($i>=$j){
		$positionhash{$group}{$i}{$seqpiece[$i]}+=$total;
		$i++;
	    }
	} else {
	    die "Missing $OTU SEQ:$seqhash{$OTU} GROUP: $grouphash{$OTU}\n";
	}
    }
}    
close (IN);
#print "Evaluating positions\n";
foreach $group (sort keys %positionhash){
    foreach $pos (sort {$a <=> $b} keys %{$positionhash{$group}}){
	foreach $base (sort keys %{$positionhash{$group}{$pos}}){
	    #keep positions where there is a lot of variability
	    if ($totalhash{$group}){
		$fraction=$positionhash{$group}{$pos}{$base}/$totalhash{$group};
		if ($fraction>0.99){
		    #98% of reads have the same base at this position
		    $removehash{$group}{$pos}{$base}++;
		    #print "Remove $pos\t$base\t$positionhash{$group}{$pos}{$base}\n" if ($group==72);
		}
	    } else {
		die "totalhash $group is 0 $totalhash{$group}\n";
	    }
	}
    }
}

#make fasta file for each group with more than 2 sequences
#print "Printing fa\n";
foreach $OTU (sort keys %seqhash){
    $group=$grouphash{$OTU};
    if ($seqhash{$OTU} && $totalhash{$group}){
	print ">${OTU}_$OTUcount{$OTU}\n$seqhash{$OTU}\n";
	(@bases)=split ("", $seqhash{$OTU});
	$i=0;
	$j=@bases;
	until ($i>=$j){
	    $i++;
	}
	print "\n";
    } else {
	die "No seqhash totalhash $OTU $seqhash{$OTU} or totalhash $group $totalhash{$group}\n";
    }
}
}
