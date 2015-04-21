#! /usr/bin/perl -w

die "Use this for AdaptML to change something (find) to something else (replace)
Usage: <file> <find> <replace> > redirect" unless (@ARGV);
($file, $find, $replace) = (@ARGV);
chomp ($file);

open (IN, "<$file" ) or die "Can't open $file\n";
while ($line =<IN>){
    chomp ($line);
    $line =~ s/$find/$replace/g;
    print "$line\n";
}
