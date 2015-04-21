#! /usr/bin/perl -w
#
#

	die "Usage: Tab_File (DNA only) Info_col Seq_Column1 Seq_Col2\n" unless (@ARGV);
	($file, $info, $seq1, $seq2) = (@ARGV);

die "Please follow command line args\n" unless ($file && $info && $seq1 && $seq2);
chomp ($info);
chomp ($seq1);
chomp ($seq2);
$info-=1;
$seq1-=1;
$seq2-=1;
open (IN, "<$file") or die "Can't open $file\n";
while ($line=<IN>){
    chomp ($line);
    (@a) = split ("\t", $line);
    ($sequence) = $a[$seq1];
    next unless ($sequence =~/[CATGXN-]/i);
    if ($sequence =~//){
	($sequence) =~ s/ //g;
    }
    
    if ($sequence =~/^t{2,100}/i){
	($edited_sequence) = $sequence =~/^t{2,100}(.+)$/i;
    } else {
	$edited_sequence = $sequence;
    }
  
  ($sequence2) = $a[$seq2];
    next unless ($sequence2 =~/[CATGXN-]/i);
    if ($sequence2 =~//){
        ($sequence2) =~ s/ //g;
    }

    if ($sequence2 =~/^t{2,100}/i){
        ($edited_sequence2) = $sequence2 =~/^t{2,100}(.+)$/i;
    } else {
        $edited_sequence2 = $sequence2;
    }    

    print ">$a[$info]\n${edited_sequence}${edited_sequence2}\n\n" if ($a[$info] && $edited_sequence && $edited_sequence2);
}
close (IN);

