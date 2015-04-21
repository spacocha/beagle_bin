#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Use this to make a translation table between fasta files
Usage: fasta_files\n" unless (@ARGV);
	
chomp (@ARGV);

$/=">";
$count=1;
foreach $file (@ARGV){
    chomp ($file);
    open (IN, "<${file}") or die "Can't open $file\n";
    while ($line=<IN>){
	chomp ($line);
	next unless ($line);
	($name, @seqs)=split ("\n", $line);
	if ($name=~/^ID[0-9]+[A-z]\/ab=[0-9]+\//){
	    ($shrtname)=$name=~/^(ID[0-9]+[A-z])\/ab=[0-9]+\//;
	} else {
	    $shrtname=$name;
	}
	($seq) = join ("", @seqs);

	if ($hash{$seq}){
	    #if the name exists, record what the new name is
	    $uniquename{$file}{$shrtname}=$hash{$seq};
	} else {
	    #create a new name
	    $mergeid="MERGE"."$count"."ID";
	    if ($allmergeids{$mergeid}){
		die "Messed up the mergeid\n";
	    }
	    $allmergeids{$mergeid}=$seq;
	    $hash{$seq}=$mergeid;
	    $uniquename{$file}{$shrtname}=$hash{$seq};
	    $count++;
	}
    }
    close (IN);
}
print "file\tname\tmergeid\n";
foreach $file (sort keys %uniquename){
    foreach $shrtname (sort keys %{$uniquename{$file}}){
	print "$file\t$shrtname\t$uniquename{$file}{$shrtname}\n";
    }
}
