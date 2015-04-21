#! /usr/bin/perl -w

die "Usage: uc.list map\n" unless (@ARGV);
($list, $map) = (@ARGV);
chomp ($list, $map);

open (IN1, "<$map" ) or die "Can't open $map\n";
while ($line1 =<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($seq, $ref)=split ("\t", $line1);
    $hash{$seq}=$ref;
}


open (IN1, "<$list" ) or die "Can't open $list\n";
while ($line1 =<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($OTUno, @seqs)=split ("\t", $line1);
    foreach $seq (@seqs){
	$OTUhash{$seq}=$OTUno;
    }
}

close (IN1);

foreach $seq (keys %hash){
    print "$seq\t$hash{$seq}";
    if ($OTUhash{$seq}){
	$printed{$OTUhash{$seq}}++;
	print "\t$OTUhash{$seq}\t$printed{$OTUhash{$seq}}\n";
    } else {
	print "\tNA\n";
    }
}

foreach $seq (keys %OTUhash){
    print "NA\tNA\t$OTUhash{$seq}\tNA\n" unless ($printed{$OTUhash{$seq}});
    $printed{$OTUhash{$seq}}++;
}
