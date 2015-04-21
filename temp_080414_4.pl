#! /usr/bin/perl -w
#
#

die "Usage: reciprical mat_eOTU1 mat_eOTU2 OU_mat > output\n" unless (@ARGV);
($recip, $mat1, $mat2, $mat3) = (@ARGV);

die "Please follow command line args\n" unless ($mat3);
chomp ($recip, $mat1, $mat2, $mat3);
open (IN, "<$recip") or die "Can't open $recip\n";
while ($line=<IN>){
    chomp ($line);
    ($OTU1, $OTU2) = split ("\t", $line);
    if ($eOTU2OUhash{$OTU1}){
	die "Already found $line $OTU1 $eOTU2OUhash{$OTU1}\n" unless ($OTU1 eq "unique");
    } else {
	$eOTU2OUhash{$OTU1}=$OTU2;
    }
    if ($OU2eOTUhash{$OTU2}){
	die "Already foun $line $OTU2 $OU2eOTUhash{$OTU2}\n" unless ($OTU2 eq "unique");
    } else {
	$OU2eOTUhash{$OTU2}=$OTU1;
    }
}
close (IN);

open (IN, "<$mat1") or die "Can't open $mat1\n";
while ($line=<IN>){
    chomp ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if (@headers){
	if ($eOTU2OUhash{$OTU}){
	    #store this data because I don't have the other mat file yet
	    $i=0;
	    $j=@pieces;
	    until ($i >=$j){
		$eOTUmathash{$OTU}{$headers[$i]}=$pieces[$i];
		$i++;
	    }
	} else {
	    die "Doesn't have a translation $OTU $eOTU2OUhash{$OTU}\n";
	}
    } else {
	(@headers)=@pieces;
    }
}
close (IN);
@headers=();
open (IN, "<$mat2") or die "Can't open $mat2\n";
while ($line=<IN>){
    chomp ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if (@headers){
        if ($eOTU2OUhash{$OTU}){
            #store this data because I don't have the other mat file yet   
	    $i=0;
	    $j=@pieces;
	    until ($i >=$j){
		$eOTUmathash{$OTU}{$headers[$i]}=$pieces[$i];
		$i++;
	    }
	}
    } else {
	(@headers)=@pieces;
    }
}
close (IN);
        
@headers=();
print "Im starting met3\n";
open (IN, "<$mat3") or die "Can't open $mat3\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    ($lins)=pop(@pieces);
    next unless ($lins);
    if (@headers){
        if ($OU2eOTUhash{$OTU}){
	    $i=0;
	    $j=@pieces;
	    until ($i >=$j){
		if ($OU2eOTUhash{$OTU} eq "unique"){
		    #it's unique, so just print out a 0
		    print "$headers[$i]\t$OTU\t$pieces[$i]\tunique\t0\n";
		} elsif ($eOTUmathash{$OU2eOTUhash{$OTU}}{$headers[$i]}){
		    print "$headers[$i]\t$OTU\t$pieces[$i]\t$OU2eOTUhash{$OTU}\t$eOTUmathash{$OU2eOTUhash{$OTU}}{$headers[$i]}\n";
		} else {
		    print "$headers[$i]\t$OTU\t$pieces[$i]\t$OU2eOTUhash{$OTU}\t0\n";
		}
		$i++;
	    }
	}
    } else {
	(@headers)=@pieces;
    }
}
close (IN);
