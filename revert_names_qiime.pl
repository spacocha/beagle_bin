#! /usr/bin/perl -w

die "Usage: unique trans> redirect\n" unless (@ARGV);

($unique, $trans) = (@ARGV);
chomp ($unique);
chomp ($trans);

$/="\n";
open (IN, "<$trans" ) or die "Can't open $trans\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($qname, $uname)=split ("\t", $line);
    $hash{$uname}=$qname;
}
close (IN);


$/=">";
open (IN, "<$unique" ) or die "Can't open $unique\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($uname, @seqs) = split ("\n", $line);
    die "No name $uname\n" unless ($hash{$uname});
    print ">$hash{$uname}\n";
    foreach $seq (@seqs){
	print "$seq";
    }
    print "\n";
}
close (IN);
