#! /usr/bin/perl -w

die "Use this for AdaptML to remove something
Usage: <file> <find> > redirect" unless (@ARGV);
($file, $find) = (@ARGV);
chomp ($file);
chomp ($find);


open (IN, "<$file" ) or die "Can't open $file\n";
while ($line =<IN>){
    chomp ($line);
    $line =~ s/${find}//g;
    print "$line\n";
}
