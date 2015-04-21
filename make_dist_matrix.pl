#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: <ab_fasta_file > \n" unless (@ARGV);
	
	chomp (@ARGV);
	($file) = (@ARGV);
$/ = ">";
open (IN, "<$file") or die "Can't open $file\n";
while ($line1 = <IN>){	
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    ($sequence) = join ("", @pieces);
    $sequence =~tr/\n//d;
    $hash{$info}=$sequence;
}


close (IN);

foreach $OTU (sort keys %hash){	
    foreach $oOTU (sort keys %hash){
	next if ($OTU eq $oOTU);
	if ($done{$OTU}{$oOTU}){
	    #does not count
	} else {
	    $done{$OTU}{$oOTU}++;
	    $done{$oOTU}{$OTU}++;
	    #does count
	    $count++;
	}
    }
}

print "$count\n";
