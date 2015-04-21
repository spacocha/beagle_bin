#! /usr/bin/perl -w

die "Usage: file > redirect\n" unless (@ARGV);

($mat)=(@ARGV);
chomp ($mat);
open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    print "$line\n" unless ($line=~/mix2/ || $line=~/mix5/ || $line=~/mix8/);
}
close (IN);


