#! /usr/bin/perl -w

die "Usage: rdp_tab data_tab namecol > redirect\n" unless (@ARGV);
($rdpfile, $datafile, $namecol) = (@ARGV);
chomp ($rdpfile);
chomp ($datafile);
chomp ($namecol);
($namecolm1)=$namecol-1;

open (IN, "<$rdpfile" ) or die "Can't open $rdpfile\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, $class) = split ("\t", $line);
    ($shortOTU)=$OTU=~/^[0-9]*\|*\**\|*(.+)$/;
    $hash{$shortOTU}=$class;
} 
close (IN);

open (IN, "<$datafile" ) or die "Can't open $datafile\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces) = split ("\t", $line);
    $first=1;
    foreach $piece (@pieces){
	if ($first){
	    print "$piece";
	    $first=();
	} else {
	    print "\t$piece";
	}
    }
    if ($hash{$pieces[$namecolm1]}){
	print "\t$hash{$pieces[$namecolm1]}\n";
    } else {
	print "\tremoved\n";
    }

}
close (IN);
