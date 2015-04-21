#! /usr/bin/perl -w

die "Usage: tab > Redirect\n" unless (@ARGV);
($tab) = (@ARGV);
chomp ($tab);

open (IN1, "<$tab" ) or die "Can't open $tab\n";
while ($line1 =<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($genome, $abund)=split ("\t", $line1);
    if ($abund){
	($newabund)=1e10*$abund;
	if ($hash{$newabund}){
	    $end=0;
	    until ($end){
		$newabund++;
		$end=1 unless ($hash{newabund});
	    }
	}
	$hash{$newabund}++;
	print "$genome\t$newabund\n";
    }
}

close (IN1);


