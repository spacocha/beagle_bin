#! /usr/bin/perl -w
#
#

	die "Use this program to run phylogenetic trees for UC groups that need to be separated
FILE must be BASE.chisq.tab and BASE.fa must be present
BASE.group may be created if necessary
Will run a tree, or make a BASE.group file accordingly
Usage: FILE threshold_value > phylist\n" unless (@ARGV);
	($file, $thresh) = (@ARGV);

	die "Please follow command line args\n" unless ($thresh);
chomp ($file);
chomp ($thresh);

    ($base) = $file=~/^(.+)\.chisq\.tab/;
    $total = 0;
    $split=0;
    %hash=();
open (IN1, "<${file}") or die "Can't open ${file}\n";
    while ($line1 = <IN1>){
	chomp ($line1);
	next unless ($line1);
#this file contains the chisq values for each member
	($first, $second, $chisq)=split ("\t", $line1);
	$hash{$first}++;
	$hash{$second}++;
	$total++;
	if ($chisq > $thresh){
	    #If there is a chisq value above this, these need to be split
	    $split++;
	}
    }
    close (IN1);
    if ($total >1 && $split){
	#I need to format the .fa for phyML because these need to be split
	print "${base}.fa\n";
#	system ("/home/digev/Softs/phyml_v2.4.4/exe/phyml_linux ${base}.phy 0 i 1 0 GTR e e 4 e BIONJ y y");
    } elsif ($total == 1 && $split){
	#I need to make the .group file and put these into different groups
	open (OUT, ">${base}.group") or die "Can't open ${base}.group\n";
	$groupno = 1;
	foreach $name (sort keys %hash){
	    print OUT "$name\t$groupno\n";
	    $groupno++;
	}
	close (OUT);
    } elsif ($total ==0){
	die "Weird $total\n";
    } else {
	#all of these can be grouped
	open (OUT, ">${base}.group") or die "Can't open ${base}.group\n";
	foreach $name (sort keys %hash){
	    print OUT "$name,1\n";
	}
	close (OUT);
    }



