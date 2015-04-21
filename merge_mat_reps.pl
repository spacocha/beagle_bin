#! /usr/bin/perl -w

die "Use this to merge replicates in a mat file
Usage: matfile > redirect\n" unless (@ARGV);

($matfile)=(@ARGV);
chomp ($matfile);
$forlinhash="Consensus Lineage";
open (IN, "<$matfile" ) or die "Can't open $matfile\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/QIIME/);
    ($OTU, @pieces)=split ("\t", $line);
    if (@headers){
	$i=0;
	($lineage)=pop(@pieces);
	if ($linhash{$OTU}{$forlinhash}){
	    die "Not equal $OTU $lineage $linhash{$OTU}{$forlinhash}\n" unless ($linhash{$OTU}{$forlinhash} eq $lineage);
	} else {
	    $linhash{$OTU}{$forlinhash}=$lineage;
	}
	$j=@pieces;
	until ($i >=$j){
	    $value=$pieces[$i];
	    $header=$headers[$i];
	    if ($header=~/^(.+)\.[0-9]+$/){
		($newheader)=$header=~/^(.+)\.[0-9]+$/;
	    } else {
		$newheader=$header;
	    }
	    $hash{$OTU}{$newheader}+=$value;
	    $allheaders{$newheader}++;
	    $i++;
	}
    } else {
	(@headers)=@pieces;
	($linname)=pop(@headers);
    }
}
close (IN);

foreach $OTU (sort keys %hash){
    print "OTU";
    foreach $header (sort keys %allheaders){
	print "\t$header";
    }
    #use the last name for the lineage
    print "\t$linname\n";
    last;
}

foreach $OTU (sort keys %hash){
    print "$OTU";
    foreach $header (sort keys %allheaders){
	if ($hash{$OTU}{$header}){
	    print "\t$hash{$OTU}{$header}";
	} else {
	    print "\t0";
	}
    }
    print "\t$linhash{$OTU}{$forlinhash}\n";
}
