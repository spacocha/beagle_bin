#! /usr/bin/perl -w
#   Edited on 04/02/12 
#
$programname="temp_051012.pl";

	die dieHelp () unless (@ARGV); 

($truefile, $matfile, $colno)=@ARGV;
chomp ($truefile, $matfile, $colno);
$colm1=$colno-1;

open (IN, "<$truefile" ) or die "Can't open $truefile\n";
@headers=();
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, $lib) =split ("\t", $line);
    if ($first){
	$first=();
    } else {
	$hash{$OTU}{$truefile}=$lib;
	$total{$truefile}+=$lib
    }
}
close (IN);

open (IN, "<$matfile" ) or die "Can't open $matfile\n";
@headers=();
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/QIIME/);
    ($OTU, @libs) =split ("\t", $line);
    if (@headers){
	($map)=pop (@libs);
	if ($map=~/27F/){
	    $hash{$map}{$matfile}=$libs[$colm1];
	} else {
	    $hash{$OTU}{$matfile}=$libs[$colm1];
	}
	$total{$matfile}+=$libs[$colm1];
    } else {
	(@headers)=(@libs);
    }
}
close (IN);

($JSvalue)=JS_value();
#print "$truefile\t$matfile\t$colno\t$JSvalue\n";

############
#subroutines
############

sub dieHelp {

die "Usage: perl $programname true_dist compare_matrix libcol > redirect\n";
}

sub JS_value {
    #pass the two OTUs that you want to compare
    #need to have matbarhash defined with all of the 
    #header values in the library
    #also need mathash defined with the count of each OTU across all libraries

    my ($JS1);
    $JS1=0;
    my ($JS2);
    $JS2=0;
    my ($newJS);
    $newJS=0;
    my ($q);
    my ($p);
    print "OTU\t$matfile\t$truefile\n";
    foreach $OTU (sort keys %hash){
	    #each is defined as the portion of the 
	if ($hash{$OTU}{$matfile}){
	    #make it a percent
	    ($p) = $hash{$OTU}{$matfile}/$total{$matfile};
	} else {
	    $p=0;
	}
	if ($hash{$OTU}{$truefile}){
	    #it is already a percent
	    ($q) = $hash{$OTU}{$truefile}/$total{$truefile};
	} else {
	    $q=0;
	}
	$hash{$OTU}{$matfile}=0 unless ($hash{$OTU}{$matfile});
	$hash{$OTU}{$truefile}=0 unless ($hash{$OTU}{$truefile});
	print "$OTU\t$hash{$OTU}{$matfile}\t$hash{$OTU}{$truefile}\n" if ($hash{$OTU}{$matfile} || $hash{$OTU}{$truefile});
	if (($q > 0) && ($p > 0)){
	    #first make the KL of x,(x+y)/2
	    $one=($p+$q)/2;
	    $two=$p/$one;
	    $three=log($two)/log(2);
	    $four=$p*$three;
	    $JS1+=$four;
            $five=$q/$one;
            $six=log($five)/log(2);
            $seven=$q*$six;
	    $JS2+=$seven;
	}
	#print "\t$JS1\t$JS2\n";
    }
    $newJS=($JS1 + $JS2)/2;
    #print "$newJS\n";
    return ($newJS);
}

