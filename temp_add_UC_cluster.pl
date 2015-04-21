#! /usr/bin/perl -w
#
#

	die "Use this program to take the UCLUST groups and make a consensus (> 75% identity) sequence to run through chimera checker
Usage: UC_file tab_file_w_FreClu_membership\n" unless (@ARGV);
	($uc, $tab) = (@ARGV);

	die "Please follow command line args\n" unless ($tab);
chomp ($uc);
chomp ($tab);

open (IN, "<$uc") or die "Can't open $uc\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/^\#/);
    ($type, $seed, $len, $one, $two, $three, $four, $five, $name, $seedname)=split (" ", $line);
    if ($type eq "S"){
	$seedname = $name;
	$seedno{$seedname}=$seed;
	#foreach name or seed there are two things
	#both the total number of names in that seed
	#and the total number of seqs for that name
	#the following counts all the seqs for that name
	#iterating over all instances count the total number of names in that seed
	$uchash{$name}=$seedname;
    } elsif ($type ne "C"){
	$uchash{$name}=$seedname;
    }
}
close (IN);

open (IN, "<$tab") or die "Can't open $tab\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($info, $lib, $fseq, $fqual, $rseq, $rqual) = split ("\t", $line);
    ($bar) = $info =~/^.+\#.*(.{7})$/;
    if ($uchash{$info}){
	#found the uc cluster for this sequence
	print "$info\t$lib\t$fseq\t$fqual\t$rseq\t$rqual\t$uchash{$info}\n";
    } else {
	print "$info\t$lib\t$fseq\t$fqual\t$rseq\t$rqual\tremoved\n";
    }

}
close (IN);
