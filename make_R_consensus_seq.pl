#! /usr/bin/perl -w
#
#

	die "Use this program to make a consensus sequence for the reverse read and concat to forward for RDP or other classification
Usage: tab fasta OTUcol R_seq_col >redirect\n" unless (@ARGV);
	($tab, $fasta, $OTUcol, $Rseqcol) = (@ARGV);

	die "Please follow command line args\n" unless ($Rseqcol);
chomp ($tab);
chomp ($fasta);
chomp ($OTUcol);
chomp ($Rseqcol);
$OTUcolm1=$OTUcol-1;
$Rseqcolm1=$Rseqcol-1;

$N= "N";

$/=">";
open (IN, "<$fasta") or die "Can't open $fasta\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs)=split ("\n", $line);
    ($sequence)=join ("", @seqs);
    $sequence=~s/ //g;
    $OTUhash{$info}=$sequence;

}
close (IN);

$/="\n";
open (IN, "<$tab") or die "Can't open $tab\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    (@linepieces) = split ("\t", $line);
    $sequence=$linepieces[$Rseqcolm1];
    next if ($sequence eq "removed");
    $OTU=$linepieces[$OTUcolm1];
    next unless ($OTU);
    next if ($OTU eq "removed");
    next unless ($OTUhash{$OTU});
    (@pieces) = split ("", $sequence);
    $j = @pieces;
    $i = 0;
    until ($i >= $j){
	$k=$i+1;
	$consensus{$OTU}{$k}{$pieces[$i]}++;
	$i++;
    }
    
}
close (IN);
#make a table of total counts per seed cluster

foreach $seedname (sort keys %consensus){
    print ">${seedname}\n";
    $printedseq = ();
    foreach $pos (sort {$a <=> $b} keys %{$consensus{$seedname}}){
	$total = 0;
	foreach $base (sort keys %{$consensus{$seedname}{$pos}}){
	    $total+= $consensus{$seedname}{$pos}{$base};
	}
	$printed = ();
	foreach $base (sort keys %{$consensus{$seedname}{$pos}}){
	    $percent = $consensus{$seedname}{$pos}{$base}/$total;
	    if ($percent > 0.75){
		if ($printedseq){
		    $printedseq = "${printedseq}"."$base";
		} else {
		    $printedseq = $base;
		}
		$printed++;
		last;
	    }
	}
	if ($printedseq){
	    $printedseq = "${printedseq}"."N" unless ($printed);
	} else {
	    $printedseq = "N" unless ($printed);
	}
    }
    $revseq=$printedseq;
    $forseq=$OTUhash{$seedname};
    #remove gaps
    $forseq=~s/-//g;
    $revseq=~s/-//g;
    (@forpiece)=split ("", $forseq);
    (@revpiece)=split ("", $revseq);
    $forno=@forpiece;
    $revno=@revpiece;
    $N="N";
    $numberN=374-$forno-$revno;
    $Nstring=${N} x ${numberN};
    ($concat) = "$forseq"."$Nstring"."$revseq";
    print "$concat\n";

}
