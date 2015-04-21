#! /usr/bin/perl -w

die "Usage: log> redirect\n" unless (@ARGV);
($log) = (@ARGV);
chomp ($log);

open (IN, "<$log" ) or die "Can't open $log\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    if ($checknext){
	#need to know if this line is positive or not
	if ($line=~/^OK/){
	    #only count if ok
	    $startcount++;
	}
	$checknext=();
    }elsif ($line=~/Working on ID[0-9]{7}M$/){
	#this is the start of a new entry
	($workingid)=$line=~/Working on (ID[0-9]{7}M)$/;
	$workingparent=();
	$startcount=0;
    }elsif ($workingid){
	if ($line=~/${workingid} is a parent/){
	    #this is the end of an entry, clear variable
	    print "Parent\t${workingid}\t$startcount\n";
	    $workingid=();
	} elsif ($line=~/^ID[0-9]{7}M is the next closest sequence to ${workingid}/){
	    $checknext=1;
	} elsif ($line=~/change ${workingid} to ID[0-9]{7}M$/){
	    ($workingparent)=$line=~/change ${workingid} to (ID[0-9]{7}M)$/;
	} elsif ($line=~/^${workingid} was designated as a child$/){
	    print "Child\t${workingid}\t$startcount\t${workingparent}\n";
	    $workingparent=();
	    $workingid=();
	}
    }
}

close (IN);

