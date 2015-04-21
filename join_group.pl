#! /usr/bin/perl -w
#
#

	die "Use this program to add the group data to the main data file for the dataset
list_of_groups file is a list of *.group in the dir and the main data file is the tab del file with all the sequencing and group data
Usage: list_of_groups tab_file namecol > Redirect\n" unless (@ARGV);
	($file1, $file2, $namecol) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file1);
chomp ($file2);
chomp ($namecol);
$namecolm1=$namecol-1;

open (IN, "<$file1") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($UClust) = $line=~/all_tab2.F.UC92.UC90.(.+)\.group$/;
		open (IN1, "<${line}") or die "Can't open ${line}\n";
		while ($line1=<IN1>){
		    chomp ($line1);
		    next unless ($line1);
		    ($name, $group)=split (",", $line1);
		    #each file is a different 0.90 uclust id group
		    #each $group is a different FreClu cluster group within that group
		    $newgroup="$UClust"."_"."$group";
		    $FChash{$name}=$newgroup;
		}
		close (IN1);
       	}
close (IN);

open (IN, "<${file2}") or die "Can't open ${file2}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces) = split ("\t", $line);
    $first=1;
    foreach $piece (@pieces){
	if ($first){
	    print "$piece";
	    $first=0;
	} else {
	    print "\t$piece";
	}
    }
    $FreClu=$pieces[$namecolm1];
    if ($FChash{$FreClu}){
	print "\t$FChash{$FreClu}\n";
    } else {
	print "\tNA\n";
    }
}
close (IN);
