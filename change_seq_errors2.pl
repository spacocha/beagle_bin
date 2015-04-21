#! /usr/bin/perl -w

die "Usage: error_file tab namecol fasta .mat_file output\n" unless (@ARGV);
($error, $tab, $namecol, $fasta, $matfile, $output) = (@ARGV);
chomp ($tab);
chomp ($namecol);
$namecolm1=$namecol-1;
chomp ($error);
chomp ($fasta);
chomp ($matfile);
chomp ($output);

$first=1;
open (IN, "<$matfile" ) or die "Can't open $matfile\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @libs) =split ("\t", $line);
    if ($first){
	$first=();
	(@headers)=@libs;
    } else {
	$i=0;
	$j=@headers;
	until ($i>$j){
	    $mathash{$OTU}{$headers[$i]}=$libs[$i] if ($headers[$i]);
	    $i++;
	}
    }
	  
}
close (IN);

open (IN, "<$error" ) or die "Can't open $error\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line=~/^Change/);
    next unless ($line);
    ($child, $parent) =$line=~/^Change (.+) \=\> (.+)$/;
    die "MISSING: $line\n" unless ($child && $parent);
    #check to see if these two are differentially distributed across libraries
    
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
