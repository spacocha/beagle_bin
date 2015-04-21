#! /usr/bin/perl -w

use Statistics::R ;
  
my $R = Statistics::R->new() ;
  
$R->startR ;
  
$R->send(q`postscript("file.ps" , horizontal=FALSE , width=500 , height=500 , pointsize=1)`) ;
$R->send(q`plot(c(1, 5, 10), type = "l")`) ;
  
$R->send(qq`x = 123 \n print(x)`) ;
my $ret = $R->read ;
  
$R->stopR() ;
