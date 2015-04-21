#! /usr/bin/perl -w

die "Usage: old new> redirect\n" unless (@ARGV);
($old, $new) = (@ARGV);
chomp ($old, $new);

open (IN, "<$old" ) or die "Can't open $old\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line=~/^Changefrom/);
    (@counts)=split (",", $line);
    $oldhash{$counts[1]}=$counts[2];
}

close (IN);

open (IN, "<$new") or die "Can't open $new\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line=~/^Changefrom/);
    (@counts)=split (",", $line);
    $newhash{$counts[1]}=$counts[2];
}

close (IN);

foreach $id (sort keys %newhash){
    if ($oldhash{$id}){
	if ($oldhash{$id} eq $newhash{$id}){
	    $same++;
	} else {
	    $diff++;
	    print "diff\t$id\t$oldhash{$id}\t$newhash{$id}\n";
	}
    } else {
	$diff++;
	print "diff\t$id\tMissing\t$newhash{$id}\n";
    }
}

print "Same: $same
Diff: $diff\n";
