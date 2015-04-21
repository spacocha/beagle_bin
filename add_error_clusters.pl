#! /usr/bin/perl -w
#
#

	die "Use this program to add the FreClu groups to tab file
Usage: FreClu_parent_child tab_file seqcol namecol> Redirect\n" unless (@ARGV);
	($parent,  $tab, $seqcol, $namecol) = (@ARGV);

	die "Please follow command line args\n" unless ($tab);
chomp ($parent);
chomp ($tab);
chomp ($seqcol);
chomp ($namecol);
$namecolm1=$namecol-1;
$seqcolm1=$seqcol-1;

open (IN, "<$parent") or die "Can't open $parent\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($child, $childid, $parent, $parentid) = split ("\t", $line);
    $parenthash{$child}=$parent;
    $namehash{$child}=$childid;
    $namehash{$parent}=$parentid;
}
close (IN);
#fix it so that only the upper level parents are represented as "parents"
foreach $child (keys %parenthash){
    $finished = ();
    $parentseq = $parenthash{$child};
    until ($finished){
	if ($parenthash{$parentseq} && $parenthash{$parentseq} ne $parentseq){
	    #means that the parent has a parent that is not itself
	    $parentseq = $parenthash{$parentseq};
	} else {
	    $finished++;
	}
    }
    $newparenthash{$child} = $parentseq;
}

open (IN, "<$tab") or die "Can't open $tab\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces) = split ("\t", $line);
    $name=$pieces[$namecolm1];
    $seq=$pieces[$seqcolm1];
    $first=1;
    foreach $piece (@pieces){
	if ($first){
	    print "$piece";
	    $first=();
	} else {
	    print "\t$piece";
	}
    }
    if ($newparenthash{$seq}){
	print "\t$namehash{$newparenthash{$seq}}\n";
    } else {
	print "\t$name\n";
    }
}
close (IN);

