#! /usr/bin/perl -w

die "Usage: input_text map> redirect\n" unless (@ARGV);
($input, $map) = (@ARGV);
chomp ($input, $map);

open (IN, "<$input" ) or die "Can't open $input\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($group, $id)=split ("\t", $line);
    $newid="$id"."_"."${group}";
    $hash{$newid}=$group;
}

close (IN);

open (IN, "<$map" ) or die "Can't open $map\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($header, $id)=split ("\t", $line);
    if ($hash{$id}){
	$counthash{$id}++;
    }
}

close (IN);

foreach $id (sort keys %hash){
    print "$id\t$hash{$id}\t";
    if ($counthash{$id}){
	print "$counthash{$id}\n";
    } else {
	print "0\n";
    }
}
