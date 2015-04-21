#! /usr/bin/perl -w
#
#

	die "Use this program to take the qiime split_libraries_astq.py fasta and make a matrix
Usage: trans_new trans_orig cutoff > Redirect\n" unless (@ARGV);
	($file1, $file2, $cutoff) = (@ARGV);
	die "Please follow command line args\n" unless ($file2);
chomp ($file1);
chomp ($file2);
chomp ($cutoff);

open (IN, "<${file1}") or die "Can't open ${file1}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU1, $OTU2)=split ("\t", $line);
    $trans1hash{$OTU1}=$OTU2;
}

open (IN, "<${file2}") or die "Can't open ${file2}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    #remove if it was removed at any step of the process
    next if ($line=~/remove/);
    ($name, $OTU)=split ("\t", $line);
    if ($name=~/^.+_[0-9]+ /){
	($lib)=$name=~/^(.+?)_[0-9]+ /;
	$alllib{$lib}++;
	if ($trans1hash{$OTU}){
	    next if ($trans1hash{$OTU}=~/remove/);
	    $OTUhash{$trans1hash{$OTU}}{$lib}++;
	    $cutoffhash{$trans1hash{$OTU}}++;
	} else {
	    die "Missing OTU trans1hash $OTU\n";
	}
    } else {
	die "Don't recognize the lib in the name $name\n";
    }
}
close (IN);

foreach $OTU (sort keys%OTUhash){
    print "OTU";
    foreach $lib (sort keys %alllib){
	print "\t$lib";
    }
    print "\n";
    last;
}

foreach $OTU (sort keys %OTUhash){
    next unless ($cutoffhash{$OTU}>=$cutoff);
    print "$OTU";
    foreach $lib (sort keys %alllib){
	if ($OTUhash{$OTU}{$lib}){
	    print "\t$OTUhash{$OTU}{$lib}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}
