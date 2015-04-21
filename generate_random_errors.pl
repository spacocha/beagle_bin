#! /usr/bin/perl -w

die "Use this program to make fake Solexa data with errors
Seq_file should have sequence and the number of occurneces in the data set
This program will ues the qual values from the solexa files to make random errors in the sequences
Usage: Sol_file_f Sol_file_r Seq_fil output" unless (@ARGV);
($solf, $solr, $seqfile, $output) = (@ARGV);
chomp ($seqfile);
chomp ($solf);
chomp ($solr);
chomp ($output);

open (IN, "<$seqfile" ) or die "Can't open $seqfile\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($sequencef, $sequencer, $occur) = split ("\t", $line);
    $genhashf{$sequencef}=$occur;
    $genhashr{$sequencef}=$sequencer;
} 
close (IN);
fastq_mat();

$/="@",
open (INF, "<$solf" ) or die "Can't open $solf\n";
open (INR, "<$solr" ) or die "Can't open $solr\n";
open (OUTF, ">${output}.F.rand" ) or die "Can't open ${output}.F.rand\n";
open (OUTR, ">${output}.R.rand" ) or die "Can't open ${output}.R.rand\n";
while ($line =<INF>){
    chomp ($line);
    $line2=<INR>;
    next unless ($line && $line2);
    ($namef, $oldseqf, $name2f, $qualf) = split ("\n", $line);
    ($namer, $oldseqr, $name2r, $qualr) = split ("\n", $line2);
    next unless ($qualf && $qualr);
    foreach $seqf (keys %genhashf){
	if ($donehash{$seqf}){
	    if ($donehash{$seqf} >=$genhashf{$seqf}){
		next;
	    } else {
		#make a new sequence
		$seq = $seqf;
		$qual=$qualf;
		($newseqf)= generate_base ($seq);
		print OUTF "\@$namef\n$newseqf\n$name2f\n$qualf\n";
		$seq=$genhashr{$seqf};
		$qual=$qualr;
                ($newseqr)= generate_base ($seq);
		print OUTR "\@$namer\n$newseqr\n$name2r\n$qualr\n";
		$donehash{$seqf}++;
		last;
	    }
	} else {
	    #generate a new sequence
	    $seq=$seqf;
	    $qual=$qualf;
	    ($newseqf)=generate_base($seq);
	    print OUTF "\@$namef\n$newseqf\n$name2f\n$qualf\n";
	    $seq=$genhashr{$seqf};
            $qual=$qualr;
            ($newseqr)=generate_base($seq);
            print OUTR "\@$namer\n$newseqr\n$name2r\n$qualr\n";
	    $donehash{$seqf}++;
	    last;
	}
    }
}
    
close (INF);
close (INR);
close (OUTF);
close (OUTR);

sub fastq_mat{

    %qualhash=("B", "0", "C", "3", "D", "4", "E", "5", "F", "6", "G", "7", "H", "8", "I", "9", "J", "10", "K", "11", "L", "12", "M", "13", "N", "14", "O", "15", "P", "16", "Q", "17", "R", "18", "S", "19", "T", "20", "U", "21", "V", "22", "W", "23", "X", "24", "Y", "25", "Z", "26", "[", "27", "\\", "28", "]", "29", "^", "30", "_", "31", "`", "32", "a", "33", "b", "34", "c", "35", "d", "36", "e", "37", "f", "38", "g", "39", "q", "40");

}

sub generate_base {
    (@seqpieces)=split ("", $seq);
    (@qualpieces)=split ("", $qual);
    $i=0;
    $newseq=();
    foreach $qualval (@qualpieces){
	$random = rand(10000);
	#random is a number between 0 and 10000                                                                                                                   
#	die "No qual $qualval $qualhash{$qualval}\n" unless ($qualhash{$qualval});
	$error = 10**(-($qualhash{$qualval}/10));
	$error10000 = $error*10000;
#	print "$error10000, $qualval\n";
	if ($random <= $error10000){
	    #change base
	    $base=$seqpieces[$i];
	    ($newbase)=change_base ($base);
	    if ($newseq){
		$newseq="$newseq"."$newbase";
	    } else {
		$newseq=$newbase;
	    }
	} else {
	    #keep base
	    if ($newseq){
		$newseq="$newseq"."$seqpieces[$i]";
	    } else {
		$newseq = $seqpieces[$i];
	    }
	}
	$i++;
    }
    return ($newseq);
}

sub change_base{
    my($base)=@_;
    my ($newbase);
    my($got);
    my(%hash);
    my($random);
    my($four);
    $four=4;
    @randbase= ("A", "T", "C", "G");
    $got=0;
    until ($got){
	$random=int(rand($four));
	$got++ unless ($randbase[$random] eq $base);
    }
    return ($randbase[$random]);
	
}
