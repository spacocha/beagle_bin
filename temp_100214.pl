#! /usr/bin/perl -w

die "Usage: list map > redirect\n" unless (@ARGV);
($list, $map) = (@ARGV);
chomp ($list, $map);

open (IN, "<${map}") or die "Can't open ${map}\n";

while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, $ref, @pieces)=split("\t", $line);
    $hash{$OTU}=$ref;
}

close (IN);

open (IN, "<${list}") or die "Can't open $list\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    $parent=$pieces[0];
    print "$parent";
    $printed=0;
    foreach $piece (@pieces){
	if ($hash{$piece}){
	    #it's a match
	    print "\t$piece,$hash{$piece}";
	    $printed++;
	}
    }
    print "\tNo match" unless ($printed);
    print "\n";
}
