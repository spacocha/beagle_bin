#! /usr/bin/perl -w

die "Usage: mat_file error_file > redirect\n" unless (@ARGV);
($mat, $error) = (@ARGV);
chomp ($error);
chomp ($mat);
#make the pvalue hash to use later

#read in the error first with suggestions on which to merge
open (IN, "<$error" ) or die "Can't open $error\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line=~/^Change/);
    next unless ($line);
    if ($line=~/^Changefrom,.+,.+,Changeto,/){
	($child, $parent) =$line=~/^Changefrom,(.+?),(.+?),Changeto,/;
    } else {
	die "Format has changed in the error file\n";
    }
    if ($done{$parent}{$child}){
	die "There's a problem with this $parent $child\n$line";
    }
    $done{$child}{$parent}++;
    $hash{$child}=$parent;
}
close (IN);

$first=1;
open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @stuff)=split ("\t", $line);
    if ($first){
	$first=0;
	#this is the header line;
    } else {
	if ($hash{$OTU}){
	    #this name has another parent
	    $OTUhash{$hash{$OTU}}{$OTU}++;
	} else {
	    $OTUhash{$OTU}{$OTU}++;
	}
    }
}
close (IN);


foreach $OTU (sort keys %OTUhash){
    print "$OTU";
    foreach $cOTU (sort keys %{$OTUhash{$OTU}}){
	next if ($OTU eq $cOTU);
	print "\t$cOTU";
    }
    print "\n";
}

