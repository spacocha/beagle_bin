#! /usr/bin/perl -w
#
#

	die "Usage: barcode seq> redirect\n" unless (@ARGV);
	($file1, $file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
fastq_mat();
	open (IN, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($lib, $bartrue, $barf1, $barf2)=split ("\t", $line);
		$hash1{$bartrue}++;
		$hash2{$barf1}++;
		$hash3{$barf2}++;
	}
	close (IN);
	
open (IN, "<$file2") or die "Can't open $file2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split (" ", $line);
#    if ($hash1{$pieces[8]}){
	(@quals)= split ("", $pieces[9]);
	$i=0;
	$total++;
	until ($i > 6){
	    $poshash{$i}+=$qualhash{$quals[$i]};
	    $i++;
	}
#   }

}

close (IN);
foreach $pos (sort {$a <=> $b} keys %poshash){
    $average=${poshash{$pos}}/${total};
    print "$pos $poshash{$pos} $average\n";
}

sub fastq_mat{

    %qualhash=("B", "0", "C", "3", "D", "4", "E", "5", "F", "6", "G", "7", "H", "8", "I", "9", "J", "10", "K", "11", "L", "12", "M", "13", "N", "14", "O", "15", "P", "16", "Q", "17", "R", "18", "S", "19", "T", "20", "U", "21", "V", "22", "W", "23", "X", "24", "Y", "25", "Z", "26", "[", "27", "\\", "28", "]", "29", "^", "30", "_", "31", "`", "32", "a", "33", "b", "34", "c", "35", "d", "36", "e", "37", "f", "38", "g", "39", "q", "40");

}
