#! /usr/bin/perl -w

die "Usage: fasta\n" unless (@ARGV);
($new) = (@ARGV);
chomp ($new);

$/=">";
open (IN, "<$new" ) or die "Can't open $new\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @seqs)=split ("\n", $line);
    $sequence=join ("", @seqs);
    (@pieces)=split ("", $sequence);
    $j=@pieces;
    $i=0;
    until ($i>=$j){
	if ($pieces[$i]=~/-/ || $pieces[$i]=~/\./){
	    $gaphash{$i}++;
	    $completehash{$name}{$i}="-";
	} else {
	    $completehash{$name}{$i}=$pieces[$i];
	}
	$i++;
    }
    $total++;
    
} 
close (IN);

foreach $name (sort keys %completehash){
    print ">$name\n";
    foreach $pos (sort {$a <=> $b} keys %{$completehash{$name}}){
	if ($gaphash{$pos}){
	    print "$completehash{$name}{$pos}" unless ($gaphash{$pos}==$total);
	} else {
	    print "$completehash{$name}{$pos}";
	}
    }
    print "\n";
}
