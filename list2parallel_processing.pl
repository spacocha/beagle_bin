#! /usr/bin/perl -w

die "Usage: list fa output > redirect_fa_list\n" unless (@ARGV);

($list, $fasta, $output)=(@ARGV);
die "Please follow command line args\n" unless ($output);
chomp ($list);
chomp ($fasta);
chomp ($output);

$handlecount=0;
open (IN, "<$list" ) or die "Can't open $list\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    $handlecount++;
    (@p)=split ("\t", $line);
    if (@p){
	$OTU=shift (@p);
	$hash{$OTU}=$handlecount;
	open (${handlecount}, ">${output}.${handlecount}.fa") or die "Can't open ${output}.${handlecount}.fa\n";
	print "${output}.${handlecount}.fa\n";
	foreach $OTU2 (@p){
	    $hash{$OTU2}=$handlecount;
	}
    }
}

close (IN);

$/=">";
open (IN, "<$fasta" ) or die "Can't open $fasta\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @seqs)=split ("\n", $line);
    ($sequence)=join ("", @seqs);
    if ($hash{$OTU}){
	$handle=$hash{$OTU};
	print ${handle} ">$OTU\n$sequence\n";
    }
}
close (IN);
