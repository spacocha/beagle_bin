#! /usr/bin/perl -w
#
# use this file to make a Solexa formated file from a tab file with seq and quals

	die "Usage: tab_file Name_col Seq_col Qual_col > Redirect\n" unless (@ARGV);
	($file2, $namecol, $seqcol, $qualcol) = (@ARGV);

	die "Please follow command line args\n" unless ($qualcol);
chomp ($file2);
chomp ($namecol);
chomp ($seqcol);
chomp ($qualcol);

$namecol-=1;
$seqcol-=1;
$qualcol-=1;

open (IN, "<$file2") or die "Can't open $file2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    (@data) = split ("\t", $line);
    $name = $data[$namecol];
    $seq = $data[$seqcol];
    $qual = $data[$qualcol];
    ($seq2) = $seq=~/^(.{89})/;
    ($qual2) = $qual=~/^(.{89})/;
    print "\@${name}\n$seq2\n+${name}\n$qual2\n" if ($seq2 && $qual2);

}
close (IN);

