#! /usr/bin/perl -w

die "This is to merge QIIME formated matrix files picked from a reference. 
They must have lineage information in the last field
Library names and lineages can not have \"QIIME\" in them
Input a file where each line is the name of a matfile to process

Usage: matfiles_list > redirect\n" unless (@ARGV);
($matfile)=(@ARGV);
chomp ($matfile);
$forlinhash="Lineage";
open (MAT, "<$matfile" ) or die "Can't open $matfile\n";
while ($mat =<MAT>){
    chomp ($mat);
    next unless ($mat);
    @headers=();
    open (IN, "<$mat" ) or die "Can't open $mat\n";
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
		$hash{$OTU}{$header}+=$value;
		$allheaders{$header}++;
		$i++;
	    }
	} else {
	    (@headers)=@pieces;
	    ($linname)=pop(@headers);
	}
    }
    close (IN);
}
close (MAT);
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
