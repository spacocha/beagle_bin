#! /usr/bin/perl -w

die "Usage: error_file mat_file> redirect\n" unless (@ARGV);
($error, $mat) = (@ARGV);
chomp ($error);
chomp ($mat);
#make the pvalue hash to use later

#read in the error first with suggestions on which to merge
open (IN, "<$error" ) or die "Can't open $error\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    if ($line=~/^Changefrom,.+,.+,Changeto,/){
	($child, $parent) =$line=~/^Changefrom,(.+?),(.+?),Changeto,/;
	if ($done{$parent}{$child}){
	    die "There's a problem with this $parent $child\n$line";
	}
	$done{$child}{$parent}++;
	$hash{$child}=$parent;
	$parenthash{$parent}++;
    } elsif ($line=~/: Done testing as child/){
	($entry)=$line=~/^(.+): Done testing as child/;
	unless ($hash{$entry}){
	    $parenthash{$entry}++;
	}
    }
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
	print "$OTU";
	foreach $piece (@stuff){
	    print "\t$piece";
	}
	print "\n";
    } else {
	($newOTU)=$OTU=~/^(ID.+M)/;
	if ($parenthash{$newOTU}){
	    print "$newOTU";
	    foreach $piece (@stuff){
		print "\t$piece";
	    }
	    print "\n";
	}
    }
}
close (IN);

