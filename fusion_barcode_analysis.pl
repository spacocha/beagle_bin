#! /usr/bin/perl
#
#

	die "Usage: <fasta File1 forward> <fasta File2 reverse> <output_prefix>\n" unless (@ARGV);
	($file1, $file2, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($file2);
chomp ($output);

$/=">";

open (IN1, "<$file1") or die "Can't open $file1\n";
$first=1;
while ($line1=<IN1>){
    #the new line split produces an empty line for the first character- skip it
    if ($first){
	$first=();
    } else {
	#remove the final newline
	chomp ($line1);
	#make sure there's something there
	next unless ($line1);
	#get the header and sequence from the line (line breaks are ">")
	($header1, $sequence1)=split("\n", $line1);
	#get the unique name from the header
	($unique)=$header1=~/^.+_[0-9]+ (.+\#[A-z]{8})\/[0-9]/;
	if ($sequence1=~/^.{20}GATCATGACCCATTTGGAGAAGATGGTGCCAGC[AC]GCCGCG/){
	    #only keep data where there's the primer linker is present
	    ($realbar, $realseq)=$sequence1=~/^(.{20})GATCATGACCCATTTGGAGAAGATGGTGCCAGC[AC]GCCGCG(.+)$/;
	    $realhash1{$unique}=$realbar;
	    $fseqhash{$unique}=$realseq;
	}
    }
}
close (IN1);
open (SEQ, ">${output}.fa") or die "Can't open $file2\n";
open (IN1, "<$file2") or die "Can't open $file2\n";
#start at 1 for the counts
$first=1;
$barcount=1;
$freadcount=1;
$rreadcount=1;
while ($line1=<IN1>){
    #skip over empty entry
    if ($first){
        $first=();
    } else {
        chomp ($line1);
        next unless ($line1);
	#capture the unique information
        ($header1, $sequence2)=split("\n", $line1);
        ($unique)=$header1=~/^.+_[0-9]+ (.+\#[A-z]{8})\/[0-9]/;
	#check if the forward read is represented
	#check if the reverse read has the right primer sequence
	if ($sequence2=~/ATTAGA[AT]ACCC[TGC][AGC]GTAGTCC$/){
	    #capture the non-primer part of the sequence
	    ($realreadr)=$sequence2=~/^(.+)ATTAGA[AT]ACCC[TGC][AGC]GTAGTCC$/;
	    if ($realhash1{$unique}){
		#get the unique 20 bp barcode
		($uniquebar)=$realhash1{$unique};
		#check whether the barcode has a unique id
		if ($donehash{$uniquebar}){
		    #get the unique id
		    $OTUn=$donehash{$uniquebar};
		} else {
		    #make a unique id
		    (@piecesc) = split ("", $barcount);
		    $these = @piecesc;
		    $zerono = 7 - $these;
		    $zerolet = "0";
		    $zeros = $zerolet x $zerono;
		    $OTUn="ID${zeros}${barcount}B";
		    $barcount++;
		    $barseqhash{$OTUn}=$uniquebar;
		    $donehash{$uniquebar}=$OTUn;
		    $donehash2{$OTUn}=$uniquebar;
		}
		#store the unique identifier as a member of the unique barcode group
		$totalbarlist{$OTUn}++;
		push (@{$barhash{$OTUn}}, $unique);
		print SEQ ">${unique}_r\n$realreadr\n>${unique}_f\n$fseqhash{$unique}\n";
	    }
	}
    }
}
close (IN1);
close (SEQ);

open (OUT, ">${output}.list") or die "Can't open ${output}.list\n";
foreach $bar (sort keys %totalbarlist){
    $countme=@{$barhash{$bar}};
    print OUT "$bar\t$barseqhash{$bar}\t$countme";
    foreach $unique (sort @{$barhash{$bar}}){
	print OUT "\t$unique";
    }
    print OUT "\n";
}
close (OUT);

#subroutines
sub revcomp{
    (@pieces) = split ("", $rc_seq);
    #make reverse complement
    $j = @pieces;
    $j-=1;
    $seq = ();
    until ($j < 0){
	if ($pieces[$j]){
	    if ($pieces[$j] eq "A"){
		$seq = "$seq"."T";
	    } elsif ($pieces[$j] eq "T"){
		$seq = "$seq"."A";
	    } elsif ($pieces[$j] eq "C"){
		$seq = "$seq"."G";
	    } elsif ($pieces[$j] eq "G"){
		$seq = "$seq"."C";
	    } elsif ($pieces[$j] eq "N"){
		$seq = "$seq"."N";
	    } else {
		die "$pieces[$j]\n";
	    }
	} else {
	    die "NO j $j\n";
	}
	$j--;
    }
    return ($seq);
}
