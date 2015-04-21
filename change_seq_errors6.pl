#! /usr/bin/perl -w

die "Usage: error_file tab namecol fasta output\n" unless (@ARGV);
($error, $tab, $namecol, $fasta, $output) = (@ARGV);
chomp ($tab);
chomp ($namecol);
$namecolm1=$namecol-1;
chomp ($error);
chomp ($output);
chomp ($fasta);
#make the pvalue hash to use later

#read in the error first with suggestions on which to merge
open (IN, "<$error" ) or die "Can't open $error\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line=~/^Change/);
    next unless ($line);
    if ($line=~/^Changefrom,(ID[0-9]{7}P),(ID[0-9]{7}P),Changeto,/){
	($child, $parent) =$line=~/^Changefrom,(ID[0-9]{7}P),(ID[0-9]{7}P),Changeto,/;
    } elsif ($line=~/Change .+? => ID[0-9]{7}P.+Alignment mistake/){
	($child, $parent) =$line=~/^Change (ID[0-9]{7}P) => (ID[0-9]{7}P)/;
    }
    if ($done{$parent}{$child}){
	die "There's a problem with this $parent $child\n$line";
    }
    $done{$child}{$parent}++;
    $hash{$child}=$parent;
}
close (IN);

open (IN, "<$tab" ) or die "Can't open $tab\n";
open (OUT, ">${output}.tab" ) or die "Can't open ${output}.tab\n";
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

