#! /usr/bin/perl -w
#
#

	die "Use this to group rdp OTUs from the output of the Solexa data analysis across libraries
Usage: list_of_libraries output\n" unless (@ARGV);
	($file1, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($output);

open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    $filehash{$line}++;
}
close (IN);

foreach $lib (keys %filehash){
    open (IN, "<$lib") or die "Can't open $lib\n";
    while ($line=<IN>){
	chomp ($line);
	next unless ($line);
	($name, $count, @seqs)=split ("\t", $line);
	$totalhash{$lib}+=$count;
	if ($count > 10){
	    $sequence = join ("_", @seqs);
	    $datahash{$lib}{$sequence}=$count;
	    $allkeys{$sequence}++;
	}
    }
    close (IN);
}

open (OUT2, ">${output}.nums") or die "Can't open ${output}.nums\n";

print OUT2 "Class";
foreach $lib (sort keys %filehash){
    print OUT2 "\t$lib";
}

print OUT2 "\n";

foreach $seq (sort keys %allkeys){
    print OUT2 "$seq";
    foreach $lib (sort keys %filehash){
	$datahash{$lib}{$seq}=0 unless ($datahash{$lib}{$seq});
	$percent = 100*($datahash{$lib}{$seq})/($totalhash{$lib});
	print OUT2 "\t$percent";
    }
    print OUT2 "\n";
}

close (OUT2);
