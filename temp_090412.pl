#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: map list > redirect\n" unless (@ARGV);
	
chomp (@ARGV);
($map, $file) = (@ARGV);


open (IN, "<${map}") or die "Can't open $map\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $ref)=split ("\t", $line);
    ($newname)=$name=~/^(ID.+M)/;
    $hash{$newname}=$ref;
}
close (IN);

open (IN, "<${file}") or die "Can't open $file\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @IDs)=split ("\t", $line);
    if ($hash{$name}){
	print "$name\t$hash{$name}\n";
    } else {
	foreach $id (@IDs){
	    if ($hash{$id}){
		print "$name\t$hash{$id}\n";
		last;
	    }
	}
    }

}
close (IN);

