#! /usr/bin/perl -w

die "Usage: error_file trans> redirect\n" unless (@ARGV);
($error, $trans) = (@ARGV);
chomp ($error);
chomp ($trans);
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

open (IN, "<$trans" ) or die "Can't open $trans\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $OTU)=split ("\t", $line);
    if ($hash{$OTU}){
	#this name has another parent
	print "$name\t$hash{$OTU}\n";
    } else {
	print "$name\t$OTU\n";
    }
}
close (IN);

