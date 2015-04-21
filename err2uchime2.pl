#! /usr/bin/perl -w

die "Usage: error_file fasta_file mat_file> redirect\n" unless (@ARGV);
($error, $fasta, $mat) = (@ARGV);
chomp ($error);
chomp ($mat);
chomp ($fasta);
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
    } elsif ($line=~/ is a parent/){
	($entry)=$line=~/^(.+) is a parent/;
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
	(@headers)=@stuff;
	$first=0;
	#this is the header line;
    } else {
	$i=0;
	$j=@stuff;
	until ($i >=$j){
	    if ($headers[$i] eq "total"){
		$i++;
	    } else {
		$mathash{$OTU}+=$stuff[$i];
		$i++;
	    }
	}
    }
}
close (IN);

$/=">";
open (IN, "<$fasta" ) or die "Can't open $fasta\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @stuff)=split ("\n", $line);
    ($seq)=join ("", @stuff);
    $seqhash{$OTU}=$seq;
}
close (IN);


foreach $OTU (sort keys %parenthash){
    if ($seqhash{$OTU} && $mathash{$OTU}){
	print ">${OTU}/ab=${mathash{$OTU}}/\n${seqhash{$OTU}}\n";
    } else {
	die "Missing sequence $OTU $seqhash{$OTU} or MAT $OTU $mathash{$OTU}\n";
    }
}

