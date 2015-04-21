#! /usr/bin/perl -w
#
#

	die "Use this program to fix errors in sequencing data
Usage: ref mat> Redirect\n" unless (@ARGV);
	($ref, $mat) = (@ARGV);

	die "Please follow command line args\n" unless ($mat);
chomp ($ref);
chomp ($mat);

use Statistics::R;

open (IN, "<$ref" ) or die "Can't open $ref\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @libs) =split ("\t", $line);
    $refhash{$OTU}++;
}
close (IN);

#record library distribution data
$first=1;
open (IN, "<$mat" ) or die "Can't open $mat\n";
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
	    $matbarhash{$headers[$i]}++ if ($headers[$i]);
	    $tvhash{$OTU}+=$libs[$i] if ($headers[$i]);
	    $i++;
	}
    }
      
}
close (IN);

#read in bp freqs for each position

$R = Statistics::R->new() ;
$R->startR ;

foreach $oid (sort keys %refhash){
    foreach $id (sort keys %mathash){
	next if ($id eq $oid || $refhash{$id});
	next unless ($tvhash{$id}>1000);
	#don't print, but pass something to R
	$string=();
	$totalnolib=();
	foreach $bar (sort keys %matbarhash){
	    $mathash{$oid}{$bar} = 0 unless ($mathash{$oid}{$bar});
	    $mathash{$id}{$bar} =0 unless ($mathash{$id}{$bar});
	    if ($mathash{$oid}{$bar} || $mathash{$id}{$bar}){
		if ($string){
		    $string="$string,"."$mathash{$oid}{$bar},$mathash{$id}{$bar}";
		} else {
		    $string="$mathash{$oid}{$bar},$mathash{$id}{$bar}";
		}
		$totalnolib++ if ($mathash{$oid}{$bar} || $mathash{$id}{$bar});
	    }
	}
	if ($totalnolib ==1){
	    #found in one library, don't evaluate
#	    print "$oid\t$id\tNA\n";
	} else {
	    #run chisq and fishers
	    $R->send(qq`alleles<-matrix(c($string),nr=2)`);
	    $R->send(q`x<-t(alleles)`);
	    #look at the correlation
	    $halfp1=$totalnolib+1;
	    $twice=$totalnolib*2;
	    $R->send(qq`a<-x[1:${totalnolib}]`);
	    $R->send(qq`b<-x[${halfp1}:${twice}]`);
	    $R->send(qq`j<-cor(a,b)`);
	    $R->send(q`print(j)`);
	    $ret4 = $R->read;
	    ($correlation)=$ret4=~/^\[[0-9].*\] (.+)$/;
	    #what do you want to do
	    print "$oid\t$id\t$correlation\n";
	}
    }
}
$R->stopR() ;
