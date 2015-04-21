#! /usr/bin/perl -w
#
#

	die "Usage: tab namecol full_seqcol correspding_qualcol aligncol outputname\n" unless (@ARGV);
	($file1, $namecol, $seqcol, $qualcol, $aligncol, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
chomp ($namecol);
chomp ($seqcol);
chomp ($qualcol);
chomp ($aligncol);
chomp ($output);
($seqcolm1)=$seqcol-1;
($aligncolm1)=$aligncol-1;
($qualcolm1)=$qualcol-1;
($namecolm1)=$namecol-1;
fastq_mat();
#first get the total counts for each aligned sequence
print "Opeing $file1\n";
open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/fffHWI-EAS413_0041:1:/);
    (@pieces)=split ("\t", $line);
    ($align1)=$pieces[$aligncolm1];
    next if ($align1=~/remove/);
    $countaseq{$align1}++;
    #assign a count number to each name
    $namecounthash{$align1}{$pieces[$namecolm1]}=$countaseq{$align1};
    #print "$align1\n";
}
close (IN);
#now pick 1,000 names (by their numbers) at most for each value
print "Picking 1,000 names\n";
$count=1000;
foreach $align1 (sort keys %countaseq){
    print "Working on: $align1\n";
    $size=$countaseq{$align1};
    if ($size>1000){
	$i = 1;
	until ($i > $count){
	    $got = ();
	    until ($got){
		($random) = int(rand($size));
		if ($randseqhash{$align1}{$random}){
		    #already recorded this number
		    $got=();
		} else {
		    #this sequence will be used
		    $randseqhash{$align1}{$random}++;
		    $got++;
		}
	    }
	    $i++;
	}
    } else {
	#there are fewer than 1,000 counts so use all of the names in the set
	foreach $name (keys %{$namecounthash{$align1}}){
	    $randseqhash{$align1}{$namecounthash{$align1}{$name}}++;
	}
    }
}

print "Opening $file1 #2\n";

open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/fffHWI-EAS413_0041:1:/);
    (@pieces)=split ("\t", $line);
    ($align1)=$pieces[$aligncolm1];
    ($name)=$pieces[$namecolm1];
    next if ($align1=~/remove/);
    #move on unless this is one of the ones to be analyzed
    die "Missing NAME: $name\tALIGN1: $align1\n" unless ($namecounthash{$align1}{$name});
    next unless ($randseqhash{$align1}{$namecounthash{$align1}{$name}});
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    $newyear = $year+1900;
    $newmonth=$mon+1;
    $lt= "$newmonth-$mday-$newyear $hour:$min:$sec";
    print "Working on: $name\t$lt\n";
    ($sequence)=$pieces[$seqcolm1];
    ($quality)=$pieces[$qualcolm1];
    $align1=~s/-//g;
    ($align2)=$pieces[$aligncolm1];
    $aligntotalhash{$align2}++;
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
