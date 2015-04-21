#! /usr/bin/perl -w

die "Usage: trans_from_Qiime > redirect\n" unless (@ARGV);
($new) = (@ARGV);
chomp ($new);

open (IN, "<$new" ) or die "Can't open $new\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $group)=split ("\t", $line);
    if ($name=~/^(.+)_[0-9]+ /){
	($lib)=$name=~/^(.+)_[0-9]+ /;
    } elsif ($name=~/\#([A-z]+?)\//){
	($lib)=$name=~/\#([A-z]+?)\//;
    }
    die "Can't get lib info $lib $name\n" unless ($lib);
    $hash{$group}{$lib}++;
    $newbarhash{$lib}++;
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
