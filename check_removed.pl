#! /usr/bin/perl -w

die "Usage: tab seqcol libcol > redirect\n" unless (@ARGV);
($tab, $seqcol, $libcol) = (@ARGV);
chomp ($tab);
chomp ($seqcol);
$seqcolm1=$seqcol-1;
chomp ($libcol);
$libcolm1=$libcol-1;

open (IN, "<$tab" ) or die "Can't open $tab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    ($sequence)=$pieces[$seqcolm1];
    ($shortseq)=$sequence=~/^(.{76})/;
    next unless ($shortseq);
    $lib=$pieces[$libcolm1];
    $hash{$shortseq}{$lib}++;
    $totalhash{$shortseq}++;
    $libhash{$lib}++;
} 
close (IN);

foreach $seq (sort {$totalhash{$b} <=> $totalhash{$a}} keys %totalhash){
    print "OTU";
    foreach $lib (sort keys %libhash){
	print "\t$lib";
    }
    print "\n";
    last;
}

foreach $seq (sort {$totalhash{$b} <=> $totalhash{$a}} keys %totalhash){
    print "$seq";
    foreach $lib (sort keys %libhash){
	if ($hash{$seq}{$lib}){
	    print "\t$hash{$seq}{$lib}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}
	    

