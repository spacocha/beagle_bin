#! /usr/bin/perl -w
#
#

	die "Usage: list UNIQUE FNUMBER\n" unless (@ARGV);
	($lfile, $UNIQUE, $FNUMBER) = (@ARGV);

	die "Please follow command line args\n" unless ($UNIQUE);
chomp ($UNIQUE);
chomp ($lfile);
chomp ($FNUMBER);

open (OUT, ">${UNIQUE}.PC2.final.list") or die "Can't open ${UNIQUE}.PC2.final.list\n";
$lineno=0;
open (IN, "<$lfile" ) or die "Can't open $lfile\n";
while ($line =<IN>){
    $lineno++;
    chomp ($line);
    next unless ($line);
    ($info, $next, @seqs)=split ("\t", $line);
    if ($next){
	print OUT "$line\n";
    } else {
	open (LOG, ">${UNIQUE}.${lineno}.process.f${FNUMBER}.log") or die "Can't open ${UNIQUE}.${lineno}.process.f${FNUMBER}.log\n";
	open (ERR, ">${UNIQUE}.${lineno}.process.f${FNUMBER}.err") or die "Can't open ${UNIQUE}.${lineno}.process.f${FNUMBER}.err\n";
	print ERR "${info} is a parent
Finished distribution based clustering\n";
	print LOG "${info} was only isolate in PC group\n";
	print LOG "${info}: Done testing as child
Finished distribution based clustering: NA\n";
    }
}
close (IN);
