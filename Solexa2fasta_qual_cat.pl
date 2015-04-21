#! /usr/bin/perl -w
#
#

	die "This program will provide only sequences where the first 92 bases if they are good quality (no B scores)
Usage: File cutoff output_name\n" unless (@ARGV);
	($file, $cutoff, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($file);
chomp ($file);
chomp ($output);
chomp ($cutoff);
$/="@";
$count=1;
open (IN, "<$file") or die "Can't open $file\n";
open (OUTTAB, ">${output}_table") or die "Can't open ${output}_table\n";
open (OUTFA, ">${output}_fasta") or die "Can't open ${output}_fasta\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, $seq1, $name2, $qual) =split("\n", $line);
		#igure out where the B's start in $qual
		$i = 0;
		(@qualscores) = split ("", $qual);
		$j = @qualscores;
		until ($i >= $j){
		    if ($qualscores[$i] eq "B"){
			#this is the beginning of bad data
			last;
			$i++;
		    } else {
			$i++;
		    }
		}
		if ($i > $cutoff){
		    ($seq) = $seq1=~/^([A-z]{$cutoff})/;
		    if ($seq =~/^[ACTG]+$/){
			if ($done{$seq}){
			    print OUTTAB"$name\t$done{$seq}\n";
			} else {
			    print OUTFA">ID_${count}\n$seq\n\n";
			    $done{$seq}="ID_${count}";
			    print OUTTAB "$name\t$done{$seq}\n";
			    $count++;
			}
		    } else {
			#don't use seqs with amb bases
		    }
		}
       	}
close (IN);
close (OUTTAB);
close (OUTFA);
