#! /usr/bin/perl -w

die "Usage: trans barfile barlength > redirect\n" unless (@ARGV);
($new, $barfile, $barlen) = (@ARGV);
chomp ($new);
chomp ($barfile);
chomp ($barlen);

open (IN, "<$barfile" ) or die "Can't open $barfile\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $bar)=split ("\t", $line);
    $allbarhash{$bar}=$name;
}
close (IN);

open (IN, "<$new" ) or die "Can't open $new\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $group)=split ("\t", $line);
    next if ($group eq "removed");
    ($bar)=$name=~/^.+\#.*([A-z]{$barlen})\/[0-9]/;
    if ($allbarhash{$bar}){
	$madeit++;
	$hash{$group}{$allbarhash{$bar}}++;
	$newbarhash{$allbarhash{$bar}}++;
    } else {
	die "NAME $name Missing bar: $bar\n";
    }
} 
close (IN);

foreach $OTU (sort keys %hash){
    print "OTU";
    foreach $bar (sort keys %newbarhash){
        print "\t$bar";
    }
    print "\n";
    last;
}
foreach $OTU (sort keys %hash){
    print "$OTU";
    foreach $bar (sort keys %newbarhash){
	$hash{$OTU}{$bar}=0 unless ($hash{$OTU}{$bar});
        print "\t$hash{$OTU}{$bar}";
    }
    print "\n";
}
