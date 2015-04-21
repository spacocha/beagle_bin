#! /usr/bin/perl -w
#
#

	die "Usage: fasta_file> Redirect\n" unless (@ARGV);
	($file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file2);


#make a table of total counts per seed cluster
    $/ = ">";
    open (IN, "<${file2}") or die "Can't open ${file2}\n";
    while ($line = <IN>){
	chomp ($line);
	next unless ($line);
	($info, @seqs) = split ("\n", $line);
	$sequence = join ("", @seqs);
	(@pieces) = split ("", $sequence);
	$total = @pieces;
	$i = 0;
	until ($i >= $total){
	    $polyhash{$i}{$pieces[$i]}++;
	    $i++;
	}
    }
    close (IN);
    $A= "A";
    $T = "T";
    $C = "C";
    $G = "G";
	foreach $position (sort {$a <=> $b} keys %polyhash){
	    $polyhash{$position}{$A} = 0 unless ($polyhash{$position}{$A});
	    $polyhash{$position}{$T} = 0 unless($polyhash{$position}{$T});
	    $polyhash{$position}{$C} = 0 unless($polyhash{$position}{$C});
	    $polyhash{$position}{$G} = 0 unless($polyhash{$position}{$G});
	    print "$position\t$polyhash{$position}{$A}\t$polyhash{$position}{$T}\t$polyhash{$position}{$C}\t$polyhash{$position}{$G}\n";
	}

