#! /usr/bin/perl -w

die "Usage: aligned_ref aligned_fa > redirect\n" unless (@ARGV);

($ref, $fasta)=(@ARGV);
chomp ($ref);
chomp ($fasta);

$/=">";
open (IN, "<$ref" ) or die "Can't open $ref\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\n", $line);
    ($seq)=join ("", @pieces);
    if ($hash{$seq}){
	print "Ref not unique\:$OTU $hash{$seq} $seq\n";
    } else {
	$hash{$seq}=$OTU;
    }
    $namehash{$OTU}=$seq;
    (@bases)=split ("", $seq);
    $i=0;
    $j=@bases;
    until ($i>=$j){
	$arefbases{$OTU}{$i}=$bases[$i];
	$i++;
    }
    $seq=~s/-//g;
    (@bases2)=split ("", $seq);
    $i=0;
    $j=@bases2;
    until ($i >=$j){
	$urefbases{$OTU}{$i}=$bases2[$i];
	$i++;
    }
}
close(IN);
print "OTU\tRef\tNo mismatches\tMismatch type\tOTUseq\tRefseq\n";
open (IN, "<$fasta" ) or die "Can't open $fasta\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split (" ", $line);
    ($seq)=join ("", @pieces);
    if ($hash{$seq}){
	print "$OTU\t$hash{$seq}\t0\tAligned\t$seq\t$seq\n";
    } else {
	(@bases)=split ("", $seq);
	($aseq)=$seq;
	$seq=~s/-//g;
	(@bases2)=split ("", $seq);
	$lowest=@bases;
	$lowestOTU=();
	$lowesttype=();
	foreach $refOTU (sort keys %arefbases){
	    $amis=0;
	    $umis=0;
	    $i=0;
	    $j=@bases;
	    until ($i>=$j){
		$amis++ unless ($bases[$i] eq $arefbases{$refOTU}{$i});
		$i++;
	    }
	    $i=0;
	    $j=@bases2;
	    until ($i>=$j){
		if ($urefbases{$refOTU}{$i}){
		    $umis++ unless ($bases2[$i] eq $urefbases{$refOTU}{$i});
		    $i++;
		} else {
		    $i++;
		}
	    }
	    if ($amis < $lowest){
		$lowest=$amis;
		$lowestOTU=$refOTU;
		$lowesttype="Aligned";
	    } 
	    if ($umis < $lowest){
		$lowest=$umis;
		$lowestOTU=$refOTU;
		$lowesttype="Unaligned";
	    }
	}
	print "$OTU\t$lowestOTU\t$lowest\t$lowesttype\t$aseq\t$namehash{$lowestOTU}\n";
    }
}
close (IN);
