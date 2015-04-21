#! /usr/bin/perl -w
#
#

	die "Usage: parentchild1 parentchild2 > Redirect\n" unless (@ARGV);
	($file1, $file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file1);
chomp ($file2);

open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($child, $parent)=split ("\t", $line);
    next unless ($child=~/^[ATGC]+$/);
    $cphash1{$child}=$parent;
}
close (IN);


open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($child, $parent)=split ("\t", $line);
		next unless ($child=~/^[ATGC]+$/);
		$cphash2{$child}=$parent;

       	}
close (IN);

#fix it so that only the upper level parents are represented as "parents"                                                                                                                                        
foreach $child (keys %cphash1){
    $finished = ();
    $parentseq = $cphash1{$child};
    until ($finished){
        if ($cphash1{$parentseq} && $cphash1{$parentseq} ne $parentseq){
                #means that the parent has a parent that is not itself                                                                                                                                           
            $parentseq = $cphash1{$parentseq};
        } else {
            $finished++;
        }
    }
    $newcphash1{$parentseq}{$child}++;
}

#fix it so that only the upper level parents are represented as "parents"                                                                                                                                        
foreach $child (keys %cphash2){
    $finished = ();
    $parentseq = $cphash2{$child};
    until ($finished){
        if ($cphash2{$parentseq} && $cphash2{$parentseq} ne $parentseq){
                #means that the parent has a parent that is not itself                                                                                                                                           
            $parentseq = $cphash2{$parentseq};
        } else {
            $finished++;
        }
    }
    $newcphash2{$parentseq}{$child}++;
}

#now, each group is represented by a single parentseq, which is a unique identifyer

foreach $parent (keys %newcphash1){
    foreach $child (keys %{$newcphash1{$parent}}){
	$total1{$parent}++;
    }
}

foreach $parent (keys %newcphash2){
    foreach $child (keys %{$newcphash2{$parent}}){
	$total2{$parent}++;
    }
}

foreach $parent (keys %total1){
    print "1\t$parent\t$total1{$parent}\n";
}

foreach$parent(keys %total2){
    print "2\t $parent\t$total2{$parent}\n";
}

