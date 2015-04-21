#! /usr/bin/perl -w

die "Usage: blast trans> redirect\n" unless (@ARGV);
($blast, $trans) = (@ARGV);
chomp ($blast, $trans);

open (IN, "<$blast" ) or die "Can't open $blast\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    $hash{$pieces[0]}++;
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
	$mathash{$well}++;
    }
}
close(IN);

foreach $well (sort keys %mathash){
    print "$well\t$mathash{$well}\t$totalcount{$well}\n";
}
