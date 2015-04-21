#! /usr/bin/perl
#
#

	die "Usage: <precluster.names> <trans> > redirect\n" unless (@ARGV);
	($file1, $file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file1);
chomp ($file2);

open (IN1, "<$file2") or die "Can't open $file2\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($name, $unique)=split("\t", $line1);
    $hash{$name}=$unique;

}
close (IN1);

open (IN1, "<$file1") or die "Can't open $file1\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($parent, $comma)=split("\t", $line1);
    if ($hash{$parent}){
	print "$hash{$parent}";
    } else {
	die "Missing translation for $parent\n";
    }
    %printed=();
    (@pieces)=split (",",$comma);
    foreach $name (@pieces){
	next if ($name eq $parent);
	if ($hash{$name}){
	    print "\t$hash{$name}" unless ($printed{$hash{$name}});
	    $printed{$hash{$name}}++;
	} else {
	    die "Missing translation for $name\n";
	}
    }
    print "\n";
}
close (IN1);
