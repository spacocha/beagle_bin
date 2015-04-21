#! /usr/bin/perl -w
#
#

	die "Usage: File output_name\n" unless (@ARGV);
	($file, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($file);
chomp ($file);
chomp ($output);
$/="@";
$count=1;
open (IN, "<$file") or die "Can't open $file\n";
open (OUTTAB, ">${output}_table") or die "Can't open ${output}_table\n";
open (OUTFA, ">${output}_fasta") or die "Can't open ${output}_fasta\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, $seq1, $name2, $useless) =split("\n", $line);
		($seq) = $seq1=~/^([A-z]{92})/;
		if ($done{$seq}){
		    print OUTTAB"$name\t$done{$seq}\n";
		} else {
		    print OUTFA">ID_${count}\n$seq\n\n";
		    $done{$seq}="ID_${count}";
		    print OUTTAB "$name\t$done{$seq}\n";
		    $count++;
		}
       	}
close (IN);
close (OUTTAB);
close (OUTFA);
