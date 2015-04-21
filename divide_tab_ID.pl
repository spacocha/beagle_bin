#! /usr/bin/perl -w

die "Usage: tab_file seqcol output\n" unless (@ARGV);
($tab, $seqcol, $output) = (@ARGV);
chomp ($tab);
chomp ($seqcol);
chomp ($output);
($seqcolm1)=$seqcol-1;

open (IN, "<$tab" ) or die "Can't open $tab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces) = split ("\t", $line);
    die "No seq $pieces[$seqcolm1] $seqcolm1 $line\n" unless ($pieces[$seqcolm1]);
    ($handle) = $pieces[$seqcolm1];
    if ($opened{$handle}){
	$first=1;
	foreach $piece (@pieces){
	    if ($first){
		print $handle "$piece";
		$first=();
	    } else {
		print $handle "\t$piece";
	    }
	}
	print $handle "\n";
    } else {
	open ($handle, ">${output}_${handle}") or die "Can't open ${output}_${handle}\n";
	$opened{$handle}++;
	$first=1;
        foreach $piece (@pieces){
            if ($first){
                print $handle "$piece";
                $first=();
            } else {
                print $handle "\t$piece";
            }
        }
        print $handle "\n";
    }
} 
close (IN);
