#! /usr/bin/perl -w

die "Usage: testing statistics, type something\n" unless (@ARGV);

use Statistics::R;
  
$R = Statistics::R->new() ;
  
$R->startR ;
  
$R->send(q`alleles <- matrix(c(12, 4, 15, 17, 25, 4), nr=3)`) ;
$R->send(q`h=fisher.test(alleles)`) ;
$R->send(qq`print(h\$p.value)`) ;
$ret = $R->read ;
  
$R->stopR() ;

print "$ret\n";
