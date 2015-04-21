#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: <rdp_file> <uc_file> Redirect output\n" unless (@ARGV);
	
	($file1, $file2) = (@ARGV);
chomp ($file1);
chomp ($file2);

	$/ = ">";
	open (IN, "<$file1") or die "Can't open $file1\n";
	while ($line1 = <IN>){	
		chomp ($line1);
		next unless ($line1);
		$sequence = ();
		($info, @pieces) = split ("\n", $line1);
		($shrt_name)=$info=~/[0-9]+\|\*\|(.+) reverse=false$/;
		next unless ($info);
		($piece) = join ("", @pieces);
      		$hash{$shrt_name}=$piece;
	}
	
	close (IN);

$/ = "\n";
open (IN, "<$file2") or die "Can't open $file2\n";
while ($line1 = <IN>){
    chomp ($line1);
    next unless ($line1);
    next if ($line1=~/^\#/);
    ($type, $seed, $len, $one, $two, $three, $four, $five, $name, $seedname)=split (" ", $line1);
    if ($type eq "S"){
	$seedname = $name;
	$seedno{$seedname}=$seed;
	#foreach name or seed there are two things
	#both the total number of names in that seed
	#and the total number of seqs for that name
	#the following counts all the seqs for that name
	#iterating over all instances count the total number of names in that seed
	$uchash{$seedname}++;
    } elsif ($type ne "C"){
	$uchash{$seedname}++;
    }

}

close (IN);

foreach $seedname (sort {$uchash{$b} <=> $uchash{$a}} keys %uchash){
    die "None $seedname\n" unless ($hash{$seedname});
    $piece = $hash{$seedname};
    ($cl1, $n1, $cl2, $n2, $cl3, $n3, $cl4,$n4, $cl5, $n5,$cl6, $n6, $cl7, $n7)= split (";", $piece);
    print "$seedname\t$uchash{$seedname}\t$cl1\tn1\t$cl2\t$n2\t$cl3\t$n3\t$cl4\t$n4\t$cl5\t$n5\t$cl6\t$n6\t$cl7\t$n7\n";
}
