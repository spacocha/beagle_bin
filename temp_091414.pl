#! /usr/bin/perl -w

die "Usage: blast list\n" unless (@ARGV);
($blast, $list) = (@ARGV);
chomp ($blast, $list);

open (IN, "<${blast}") or die "Can't open $blast\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($id, $mock)=split ("\t", $line);
    ($newid)=$id=~/^(.+);/;
    $bestblast{$newid}=$mock;
    $altid{$newid}=$id;
}

close (IN);
open (IN, "<${list}") or die "Can't open $list\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    ($id)=$pieces[0];
    if ($bestblast{$id}){
	foreach $piece (@pieces){
	    if ($bestblast{$piece}){
		if ($bestblast{$piece} eq $bestblast{$id}){
		    print "Good\t$altid{$piece}\t$bestblast{$piece}\t$altid{$id}\t$bestblast{$id}\n";
		} else {
		    print "Bad\t$altid{$piece}\t$bestblast{$piece}\t$altid{$id}\t$bestblast{$id}\n";
		}
	    } else {
		print "Missign $piece\n";
	    }
	}
    } else {
	print "Missing $id\n";
    }

}

close (IN);


