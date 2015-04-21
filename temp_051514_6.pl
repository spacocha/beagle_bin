#! /usr/bin/perl -w

die "Usage: blast trans> redirect\n" unless (@ARGV);
($blast, $trans) = (@ARGV);
chomp ($blast, $trans);


open (IN, "<$blast" ) or die "Can't open $blast\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    if ($pieces[3]==77 && $pieces[4]==0){	
	$hash{$pieces[0]}++;
    }
}

close (IN);

open (IN, "<$trans" ) or die "Can't open $trans\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($head, $id)=split ("\t", $line);
    ($well)=$head=~/^(.+?)_[0-9]+ /;
    $totalcount{$well}++;
    if ($hash{$id}){
	$mathash{$id}{$well}++;
    }
}
close(IN);

print "OTU";
foreach $well (sort keys %totalcount){
    print "\t$well";
}
print "\n";

foreach $id (sort keys %mathash){
    print "$id";
    foreach $well (sort keys %totalcount){
	if ($mathash{$id}{$well}){
	    print "\t$mathash{$id}{$well}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}

print "Total";
foreach $well (sort keys %totalcount){
    print "\t$totalcount{$well}";
}
print "\n";
