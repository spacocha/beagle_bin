#! /usr/bin/perl -w

die "Usage: merge_table.txt mat position> redirect\n" unless (@ARGV);
($merge, $mat, $pos) = (@ARGV);
chomp ($merge);
chomp ($mat);
chomp ($pos);
$posm1=$pos-1;

$first=1;
open (IN, "<$merge" ) or die "Can't open $merge\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    if ($first){
	$first=();
    } else {
	if ($pieces[$posm1]=~/ID[0-9]{7}M/){
	    $hash{$pieces[$posm1]}=$pieces[0];
	}
    }
	
}

close (IN);

$first=1;
open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if ($first){
	print "$OTU";
	foreach $piece (@pieces){
	    print "\t$piece";
	}
	$first=();
	print "\n";
    } else {
	if ($hash{$OTU}){
	    print "$hash{$OTU}";
	    foreach $piece (@pieces){
		print "\t$piece";
	    }
	    print "\n";
	} else {
	    die "Doesn't have a translation $OTU $hash{$OTU}\n";
	}
    }
}
