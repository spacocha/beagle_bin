#! /usr/bin/perl -w
#
#

die "Usage: mat_file\n" unless (@ARGV);
($mat) = (@ARGV);

die "Please follow command line args\n" unless ($mat);
chomp ($mat);

open (IN, "<$mat") or die "Can't open $mat\n";
while ($line=<IN>){
    chomp ($line);
    ($label, $lib, $number, @abunds) = split ("\t", $line);
    if (@OTUs){
	next unless ($label==0.03);
	$j=@abunds;
	$i=0;
	until ($i>=$j){
	    if ($mathash{$OTUs[$i]}{$lib}){
		die "Something is funky $mathash{$OTUs[$i]}{$lib} $lib $i $abunds[$i] $OTUs[$i]\n";
	    } else {
		$mathash{$OTUs[$i]}{$lib}=$abunds[$i];
		$allOTUs{$OTUs[$i]}++;
		$allibs{$lib}++;
	    }
	    $i++;
	}
    } else {
	@OTUs=@abunds;
    }

}
close (IN);

print "OTU";
foreach $lib (sort keys %allibs){
    print "\t$lib";
}
print "\n";
foreach $OTU (sort keys %allOTUs){
    print "$OTU";
    foreach $lib (sort keys %allibs){
	if ($mathash{$OTU}{$lib}){
	    print "\t$mathash{$OTU}{$lib}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}
