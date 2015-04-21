#! /usr/bin/perl -w
#
#

	die "Usage: map mat > Redirect\n" unless (@ARGV);
($map, $mat) = (@ARGV);
chomp ($map, $mat);

open (SEQ, "<$map") or die "Can't open $map\n";
while ($line=<SEQ>){
    chomp ($line);
    next unless ($line);
    ($OTU, $isolate, $OTUseq, $isolateseq)=split ("\t", $line);
    if ($isolatehash{$isolate}){
	die "double isolate map $isolate\n";
    } else {
	$isolatehash{$isolate}=$OTU;
    }
    if ($OTUhash{$OTU}){
	$OTUhash{$OTU}="$OTUhash{$OTU}".","."$isolate";
    } else {
	$OTUhash{$OTU}=$isolate;
    }
}
close (SEQ);

open (RDP, "$mat") or die "Can't open $mat\n";
while ($line=<RDP>){
    chomp ($line);
    next unless ($line);
    ($id, @seqs)=split ("\t", $line);
    if (@headers){
	$i=0;
	$j=@headers;
	until ($i>=$j){
	    $totalhash{$headers[$i]}+=$seqs[$i];
	    $i++;
	}
	if ($OTUhash{$id}){
	    print "$line\t$OTUhash{$id}\n";
	}
    } else {
	(@headers)=@seqs;
	print "$line\n";
    }
}
close (RDP);

print "Total";
foreach $head (@headers){
    print "\t$totalhash{$head}";
}
print "\n";
