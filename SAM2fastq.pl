#! /usr/bin/perl -w

die "Usage: file output_prefix\n" unless (@ARGV);
($file1, $prefix) = (@ARGV);
chomp ($file1, $prefix);

open (IN1, "<${file1}") or die "Can't open $file1\n";
open (OUT1, ">${prefix}_1.fastq") or die "Can't open ${prefix}_1.fastq\n";
open (OUT2, ">${prefix}_2.fastq") or die "Can't open ${prefix}_2.fastq\n";
while ($line1 =<IN1>){
    next if ($line1=~/^@/);
    chomp ($line1);
    ($name1, $flag1, $three1, $four1, $five1, $six1, $seven1, $eight1, $nine1, $ten1, $eleven1)=split ("\t", $line1);
    #check to see if this one is supplemental
    if ($flag1 & 0x800){
	#it is supplemental, get next line
	next;
    }
    ($line2=<IN1>);
    chomp ($line2);
    ($name2, $flag2, $three2, $four2, $five2, $six2, $seven2, $eight2, $nine2, $ten2, $eleven2)=split ("\t", $line2);
    #check if this is supplemental
    if ($flag2 & 0x800){
	#it is, get next line
	$getout=();
	until ($getout){
	    ($line2=<IN1>);
	    chomp ($line2);
	    ($name2, $flag2, $three2, $four2, $five2, $six2, $seven2, $eight2, $nine2, $ten2, $eleven2)=split ("\t", $line2);
	    if ($flag2 & 0x800){
		$getout=();
	    } else{
		$getout++;
	    }
	}
    }
    die "Names don't match $name1 $name2\n" unless ($name1 eq $name2);
    unless ($flag1 & 0x800){
	if ($flag1 & 0x10){
	    ($newten1)=rev_comp($ten1);
	    ($neweleven1)=rev($eleven1);
	    $ten1=$newten1;
	    $eleven1=$neweleven1;
	}
	print OUT1 "\@${name1}/1\n$ten1\n+${name1}/1\n${eleven1}\n";
	if ($flag2 & 0x10){
	    ($newten2)=rev_comp($ten2);
	    ($neweleven2)=rev($eleven2);
	    $ten2=$newten2;
	    $eleven2=$neweleven2;
	}
	print OUT2 "\@${name2}/2\n$ten2\n+${name2}/2\n${eleven2}\n";
    }
 
}

close (IN1);

$three1=();
$three2=();
$four1=();
$four2=();
$five1=();
$five2=();
$six1=();
$six2=();
$seven1=();
$seven2=();
$eight1=();
$eight2=();
$nine1=();
$nine2=();
$flag2=();

