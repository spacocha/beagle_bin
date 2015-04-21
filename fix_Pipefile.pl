#! /usr/bin/perl -w
#
#

	die "Usage: variables_file sh_file \n" unless (@ARGV);
	($file, $file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file);
chomp ($file);
chomp ($file2);

open (IN, "<$file") or die "Can;t open $file\n";
	while ($line=<IN>){
		chomp ($line);
		($variable, $varname)=split ("=", $line);
		$hash{$variable}=$varname;

       	}
close (IN);

open (IN, "${file2}") or die "Can't open ${file2}\n";
while ($line=<IN>){
    chomp ($line);
    ($variable, $varname) = split ("=", $line);
    if ($hash{$variable}){
	print "${variable}=$hash{$variable}\n";
    } else {
	print "$line\n";
    }
}
close (IN);
