#! /usr/bin/perl -w

die "Include the OTU name, the position you want in the full length read
Usage: compare_OTU_name trans_OTU_file position fastq > redirect\n" unless (@ARGV);
($compare, $trans, $pos1, $fastq) = (@ARGV);
chomp ($pos1);
chomp ($trans);
chomp ($fastq);
chomp ($compare);

open (IN, "<$trans" ) or die "Can't open $trans\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $OTU)=split ("\t", $line);
    ($lib, $fqname, @others)=split (" ", $name);
    $namehash{$fqname}++ if ($OTU eq $compare);
}
close (IN);

fastq_mat();
$pos1-=1;

$/="@";
open (IN, "<$fastq" ) or die "Can't open $fastq\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name1, $fseq, $name2, $fqual)=split ("\n", $line);
    next unless ($namehash{$name1});
    (@fqualpieces)=split ("", $fqual);
    if ($qualhash{$fqualpieces[$pos1]}){
	$refhash{$qualhash{$fqualpieces[$pos1]}}++;
    } else {
	die "No qual hash $fqualpieces[$pos1] $pos1 $fqualshrt $name1\n";
    }
}
close (IN);

foreach $qual (sort keys %refhash){
    print "$pos1\t$qual\t$refhash{$qual}\n";
}


sub fastq_mat{

    %qualhash=("B", "0", "C", "3", "D", "4", "E", "5", "F", "6", "G", "7", "H", "8", "I", "9", "J", "10", "K", "11", "L", "12", "M", "13", "N", "14", "O", "15", "P", "16", "Q", "17", "R", "18", "S", "19", "T", "20", "U", "21", "V", "22", "W", "23", "X", "24", "Y", "25", "Z", "26", "[", "27", "\\", "28", "]", "29", "^", "30", "_", "31", "`", "32", "a", "33", "b", "34", "c", "35", "d", "36", "e", "37", "f", "38", "g", "39", "h", "40", "i", "41");

}
