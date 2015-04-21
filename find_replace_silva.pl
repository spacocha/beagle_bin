#! /usr/bin/perl

die "Use this for AdaptML to change something (find) to something else (replace)
Usage: <file>  > redirect\n" unless (@ARGV);
($file) = (@ARGV);
chomp ($file);

open (IN, "<$file" ) or die "Can't open $file\n";
while ($line =<IN>){
    chomp ($line);
    $line =~ s/^\.+//g;
    $line =~ s/\.+$//g;
    $line =~ s/-//g;
    print "$line\n";
}
