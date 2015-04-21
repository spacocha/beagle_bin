#! /usr/bin/perl -w
#
#

	die "Usage: tab full_seqcol correspding_qualcol aligncol> redirect\n" unless (@ARGV);
	($file1, $seqcol, $qualcol, $aligncol) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
chomp ($seqcol);
chomp ($qualcol);
chomp ($aligncol);
($seqcolm1)=$seqcol-1;
($aligncolm1)=$aligncol-1;
($qualcolm1)=$qualcol-1;
fastq_mat();
open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    ($align1)=$pieces[$aligncolm1];
    ($sequence)=$pieces[$seqcolm1];
    ($quality)=$pieces[$qualcolm1];
    $align1=~s/-//g;
    ($align2)=$pieces[$aligncolm1];
    ($front, $aseq, $back)=$sequence=~/^(.*)($align1)(.*)$/;
    $i=split ("", $front);
    $k=split ("", $back);
    ($fqual, $aqual, $bqual)=$quality=~/^(.{$i})(.+)(.{$k})$/;
    $aindex=0;
    $qindex=0;
    $qseq=();
    (@align2pieces)=split ("", $align2);
    (@qualpieces)=split ("", $aqual);
    (@seqpieces)=split ("", $aseq);
    $j=@align2pieces;
    until ($aindex >=$j){
	if ($align2pieces[$aindex] eq "-"){
	    #this position is a gap so I want to make a gap in the qual too
	    $poshash{$aindex}="-";
	} else {
	    #this position should correspond to the next qual
	    die "Not working SEQ $seqpieces[$qindex] ALIGN $align2pieces[$aindex]\n" unless ($seqpieces[$qindex] eq $align2pieces[$aindex]);
	    $posqual=$qualpieces[$qindex];
	    die "No qualhash value $posqual\n" unless ($qualhash{$posqual});
	    $poshash{$aindex}+=$qualhash{$posqual};
	    $totalhash{$aindex}++;
	    $qindex++;
	}
	$aindex++;
    }
	    
}


close (IN);

foreach $apos (sort {$a <=> $b} keys %poshash){
    if ($poshash{$apos} eq "-"){
	#print "$apos\t-\n";
    } else {
	$ave=$poshash{$apos}/$totalhash{$apos};
	print "$apos\t$ave\n";
    }
}


sub fastq_mat{

    %qualhash=("B", "0", "C", "3", "D", "4", "E", "5", "F", "6", "G", "7", "H", "8", "I", "9", "J", "10", "K", "11", "L", "12", "M", "13", "N", "14", "O", "15", "P", "16", "Q", "17", "R", "18", "S", "19", "T", "20", "U", "21", "V", "22", "W", "23", "X", "24", "Y", "25", "Z", "26", "[", "27", "\\", "28", "]", "29", "^", "30", "_", "31", "`", "32", "a", "33", "b", "34", "c", "35", "d", "36", "e", "37", "f", "38", "g", "39", "q", "40");

}
