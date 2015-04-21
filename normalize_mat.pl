#! /usr/bin/perl -w

die "Usage: mat_total mat > redirect\n" unless (@ARGV);
($file, $mat) = (@ARGV);
chomp ($file);
chomp ($mat);

open (IN, "<$file" ) or die "Can't open $file\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($lib, $mattotal)=split ("\t", $line);
    $hash{$lib}=$mattotal;
}
close (IN);
@headers=();
open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    print "$OTU";
    if (@headers){
	$i=0;
	$j=@pieces;
	until ($i >=$j){
	    if ($hash{$headers[$i]}){
		$frac=$pieces[$i]/$hash{$headers[$i]};
		print "\t$frac";
	    } else {
		die "No hash for $headers[$i]\n";
	    }
	    $i++;
	}     
    } else {
	(@headers)=@pieces;
	foreach $head (@headers){
	    print "\t$head";
	}
    }
    print "\n";
}
close (IN);

