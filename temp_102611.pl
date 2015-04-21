#! /usr/bin/perl -w

die "Usage: mock_check otu_table\n" unless (@ARGV);
($file1, $file2) = (@ARGV);
chomp ($file1);
chomp($file2);

open (IN, "<$file1" ) or die "Can't open $file1\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($ref, $output)=split ("\t", $line);
    if ($hash{$ref}){
	die "Duplicated ref: $output $hash{$ref}\n";
    } else {
	$hash{$ref}=$output;
    }
}
close (IN);

open (IN, "<$file2" ) or die "Can't open $file2\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($ref, @counts)=split ("\t", $line);
    if ($hash{$ref}){
	print "$hash{$ref}";
    } else {
	print "$ref";
    }
    foreach $piece (@counts){
	print "\t$piece";
    }
    print "\n";
}
close (IN);
