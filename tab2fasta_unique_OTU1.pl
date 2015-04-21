#! /usr/bin/perl -w

die "Usage: tab_file output\n" unless (@ARGV);
($new, $output) = (@ARGV);
chomp ($new);
chomp ($output);

open (OUT, ">${output}.tab") or die "Can't open ${output}.tab\n";
open (IN, "<$new" ) or die "Can't open $new\n";
$fcount=1;
$rcount=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($info, $lib, $fseq, $fqual, $rseq, $rqual) = split ("\t", $line);
    unless ($fhash{$fseq}){
	(@pieces) = split ("", $fcount);
	$these = @pieces;
	$zerono = 7 - $these;
	$zerolet = "0";
	$zeros = $zerolet x $zerono;
	$fOTU="ID"."$zeros"."$fcount"."P";
	$fhash{$fseq}=$fOTU;
	$fcount++;
    }
    unless ($rhash{$rseq}){
        (@pieces) = split ("", $rcount);
        $these = @pieces;
        $zerono = 7 - $these;
        $zerolet = "0";
        $zeros = $zerolet x $zerono;
	$rOTU="ID"."$zeros"."$rcount"."R";
        $rhash{$rseq}=$rOTU;
	$rcount++;
    }
    print OUT "$info\t$lib\t$fhash{$fseq}\t$rhash{$rseq}\n";
    $fOTUcount{$fhash{$fseq}}++;
    $rOTUcount{$rhash{$rseq}}++;
} 
close (IN);
close (OUT);

open (OUTF, ">${output}_F.fa") or die "Can't open ${output}_F.fa\n";
foreach $seq (keys %fhash){
    print OUTF ">$fhash{$seq}_$fOTUcount{$fhash{$seq}}\n$seq\n";
}
close (OUTF);

open (OUTR, ">${output}_R.fa") or die "Can't open ${output}_R.fa\n";
foreach $seq (keys %rhash){
    print OUTR ">$rhash{$seq}_$rOTUcount{$rhash{$seq}}\n$seq\n";
}
close (OUTR);

