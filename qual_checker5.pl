#! /usr/bin/perl -w
#
#

	die "Usage: OTU2t OTU2f OTU1t tab full_seqcol correspding_qualcol outputname\n" unless (@ARGV);
	($OTU2t, $OTU2f, $OTU1t, $file1, $seqcol, $qualcol, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($seqcol);
chomp ($qualcol);
chomp ($OTU2f);
chomp ($OTU2t);
chomp ($OTU1t);
chomp ($output);
($seqcolm1)=$seqcol-1;
($qualcolm1)=$qualcol-1;
$/=">";
open (IN, "<$OTU2f") or die "Can't open $OTU2f\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs)=split ("\n", $line);
    ($sequence)=join ("", @seqs);
    ($OTU, $abund)=$info=~/^(.+)_([0-9]+)$/;
    if ($abund>=10){
	$alignhash1{$OTU}=$sequence;
    }
}
close (IN);

$/="\n";
open (IN, "<$OTU2t") or die "Can't open $OTU2t\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU1, $OTU2)=split ("\t", $line);
    if ($alignhash1{$OTU2}){
	#Its present at more than 10 counts in aligned file
        $alignhash2{$OTU1}=$alignhash1{$OTU2};
    }
}
close (IN);

open (IN, "<$OTU1t") or die "Can't open $OTU1t\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $lib, $OTU1)=split ("\t", $line);
    if ($alignhash2{$OTU1}){
        #Its present at more than 10 counts in aligned file                                                                                  
        $alignhash3{$name}=$alignhash2{$OTU1};
    }
}
close (IN);


$/="\n";
fastq_mat();
open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    if ($alignhash3{$pieces[0]}){
	($align1)=$alignhash3{$pieces[0]};
	($align2)=$alignhash3{$pieces[0]};
    }else{
	next;
    }
    next if ($align1=~/remove/);
    ($sequence)=$pieces[$seqcolm1];
    ($quality)=$pieces[$qualcolm1];
    $align1=~s/-//g;
    $aligntotalhash{$align2}++;
    ($front, $aseq, $back)=$sequence=~/^(.*)($align1)(.*)$/;
    $i=split ("", $front);
    $k=split ("", $back);
    ($fqual, $aqual, $bqual)=$quality=~/^(.{$i})(.+)(.{$k})$/;
    $aindex=0;
    $qindex=0;
    (@align2pieces)=split ("", $align2);
    (@qualpieces)=split ("", $aqual);
    (@seqpieces)=split ("", $aseq);
    $j=@align2pieces;
    until ($aindex >=$j){
	if ($align2pieces[$aindex]=~/[ATGC]/){
            #this position should correspond to the next qual
	    die "Not working SEQ $seqpieces[$qindex] ALIGN $align2pieces[$aindex]\n" unless ($seqpieces[$qindex] eq $align2pieces[$aindex]);
            $posqual=$qualpieces[$qindex];
            die "No qualhash value $posqual $align2pieces[$aindex] $align2 $aqual $aseq\n" unless ($qualhash{$posqual});
            $poshash{$align2}{$aindex}+=$qualhash{$posqual};
            $poshashval{$align2}{$aindex}{$qualhash{$posqual}}++;
            $totalhash{$align2}{$aindex}++;
            $qindex++;
	} else {
	    #this position is a gap so I want to make a gap in the qual too
	    $poshash{$align2}{$aindex}="-";
	    #do not advance the qindex
	}
	$aindex++;
    }
}


close (IN);

open (OUTFA, ">${output}.fa") or die "Can't open ${output}.fa\n";
open (OUTQUAL, ">${output}.qual") or die "Can't open ${output}.qual\n";
open (OUTSTDV, ">${output}.std") or die "Can't open ${output}.std\n";
$idcount=1;
foreach $align (sort {$aligntotalhash{$b} <=> $aligntotalhash{$a}} keys %aligntotalhash){
    (@pieces) = split ("", $idcount);
    $these = @pieces;
    $zerono = 7 - $these;
    $zerolet = "0";
    $zeros = $zerolet x $zerono;
    print OUTFA ">ID${zeros}${idcount}P\n$align\n";
    print OUTQUAL ">ID${zeros}${idcount}P_${aligntotalhash{$align}}\n";
    print OUTSTDV ">ID${zeros}${idcount}P_${aligntotalhash{$align}}\n";
    $idcount++;
    $first=1;
    foreach $apos (sort {$a <=> $b} keys %{$poshash{$align}}){
	if ($poshash{$align}{$apos}=~/[0-9]/){
	    $ave=$poshash{$align}{$apos}/$totalhash{$align}{$apos};
	    %hash=();
	    $count=1;
	    foreach $val (keys %{$poshashval{$align}{$apos}}){
		$hash{$count}=$val;
		$count++;
	    }
	    ($std)=stdev();
	    if ($first){
		print OUTQUAL "$ave";
		print OUTSTDV "$std";
		$first=();
	    } else {
		print OUTQUAL "\t$ave";
		print OUTSTDV "\t$std";
	    }
	} else {
	    if ($first){
		print OUTQUAL "-";
		print OUTSTDV "-";
		$first=();
	    } else {
		print OUTQUAL "\t-";
		print OUTSTDV "\t-";
	    }
	    
	}
    }
    print OUTQUAL "\n";
    print OUTSTDV "\n";
}

sub fastq_mat{

    %qualhash=("B", "0", "C", "3", "D", "4", "E", "5", "F", "6", "G", "7", "H", "8", "I", "9", "J", "10", "K", "11", "L", "12", "M", "13", "N", "14", "O", "15", "P", "16", "Q", "17", "R", "18", "S", "19", "T", "20", "U", "21", "V", "22", "W", "23", "X", "24", "Y", "25", "Z", "26", "[", "27", "\\", "28", "]", "29", "^", "30", "_", "31", "`", "32", "a", "33", "b", "34", "c", "35", "d", "36", "e", "37", "f", "38", "g", "39", "h", "40", "i", "41");

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

    $total = (keys %hash);
    return $std = 0 if ($total <= 1);               #can not find stdev if there are no values
    $sum =0;                                        #blank this value

    foreach $value (keys %hash){                    #find the sum of all values
	$sum+=$hash{$value};
    }

    $average = $sum/$total;                         #calculate the mean or average
        
    $ysq = 0;                                       #clear values
    $ysum = 0;

    foreach $value (keys %hash){                    #for each find the square of the difference from the mean
	$y = $hash{$value} - $average;
	$ysq = $y*$y;
	$ysum+=$ysq;                            #sum all squared values
    }
        
    $std = sqrt($ysum/($total - 1));                #find the square root of the squared sum divided by total -1
    return $std;
}
