#! /usr/bin/perl -w

die "Usage: list\n" unless (@ARGV);
($list) = (@ARGV);
chomp ($list);

open (IN, "<$list" ) or die "Can't open $list\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    $hash{$line}++;
}
close (IN);

$/=">";
foreach $file (sort keys %hash){
    open (IN2, "<$file" ) or die "Can't open $file\n";
    while ($line =<IN2>){
	chomp ($line);
	next unless ($line);
	($ref, @libs)=split ("\n", $line);
	($seq)=join("", @libs);
	#$seq=~s/-//g;
	$seq=~s/\.//g;
	$number=split ("", $seq);
	$dist{$number}{$file}++;
	$totaldist{$number}++;
	$totalfile{$file}++;
    }
    close (IN2);
} 

foreach $num (sort keys %totaldist){
    foreach $file (sort keys %totalfile){
	$dist{$num}{$file}=0 unless ($dist{$num}{$file});
    }
}

foreach $num (sort keys %totaldist){
    print "Num";
    foreach $file (sort keys %totalfile){
	print "\t$file";
    }
    print "\n";
    last;
}

foreach $num (sort keys %totaldist){
    print "$num";
    foreach $file (sort keys %totalfile){
        print "\t$dist{$num}{$file}";
    }
    print "\n";
}

