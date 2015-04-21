#! /usr/bin/perl -w

die "Usage: error_file tab namecol fasta output\n" unless (@ARGV);
($error, $tab, $namecol, $fasta, $output) = (@ARGV);
chomp ($tab);
chomp ($namecol);
$namecolm1=$namecol-1;
chomp ($error);
chomp ($fasta);

open (IN, "<$error" ) or die "Can't open $error\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line=~/^Change/);
    next unless ($line);
    ($child, $parent) =$line=~/^Change (.+) \=\> (.+)$/;
    $hash{$child}=$parent;
}
close (IN);

open (IN, "<$tab" ) or die "Can't open $tab\n";
open (OUT, ">${output}.tab") or die "Can't open ${output}.tab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    $first=1;
    foreach $piece (@pieces){
	if ($first){
	    print OUT "$piece";
	    $first=();
	} else {
	    print OUT "\t$piece";
	}
    }
    if ($hash{$pieces[$namecolm1]}){
	print OUT "\t$hash{$pieces[$namecolm1]}\n";
    } else {
	print OUT "\t$pieces[$namecolm1]\n";
    }
} 
close (IN);
close (OUT);

$/=">";
open (IN, "<$fasta" ) or die "Can't open $fasta\n";
open (OUT, ">${output}.fa") or die "Can't open ${output}.fa\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @seqs) =split ("\n", $line);
    ($sequence)=join ("", @seqs);
    unless ($hash{$name}){
	print OUT ">$name\n$sequence\n";
    }

}
close (IN);
close (OUT);
