#! /usr/bin/perl -w

die "Usage: trans outlists_comma_sep > redirect\n" unless (@ARGV);

($map, $poly)=(@ARGV);
chomp ($map, $poly);

open (IN, "<$map" ) or die "Can't open $map\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $OTU)=split ("\t", $line);
    ($name1) =split (" ", $name);
    $hash{$name1}=$OTU;
}
close (IN);

(@files)=split (",", $poly);
foreach $file (@files){
    open (IN, "<$file" ) or die "Can't open $file\n";
    while ($line =<IN>){
	chomp ($line);
	next unless ($line);
	($ref, @names)=split ("\t", $line);
	foreach $name (@names){
	    if ($hash{$name}){
		$refhash{$ref}{$hash{$name}}++;
	    } else {
		die "Missing $name $hash{$name}\n";
	    }
	}
    }
    
    close (IN);
}

foreach $ref (sort keys %refhash){
    print "$ref";
    foreach $OTU (sort keys %{$refhash{$ref}}){
	print "\t$OTU";
    }
    print "\n";
}
