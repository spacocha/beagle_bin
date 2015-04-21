#! /usr/bin/perl -w
#
#

	die "Usage: UC_file fasta_file> Redirect\n" unless (@ARGV);
	($file1, $file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file1);
chomp ($file2);


open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/^#/);
    ($type, $seed, $len, $one, $two, $three, $four, $five, $name, $seedname)=split (" ", $line);
    if ($type eq "S"){
	$seedname = $name;
	$uchash{$name}=$seedname;
    } elsif ($type ne "C"){
	$uchash{$name}=$seedname;
    }
}
close (IN);

#make a table of total counts per seed cluster
    $/ = ">";
    open (IN, "<${file2}") or die "Can't open ${file2}\n";
    while ($line = <IN>){
	chomp ($line);
	next unless ($line);
	($info, @seqs) = split ("\n", $line);
	$sequence = join ("", @seqs);
	die "Not in uc $info\n" unless ($uchash{$info});
	(@pieces) = split ("", $sequence);
	$total = @pieces;
	$i = 0;
	until ($i >= $total){
	    $polyhash{$uchash{$info}}{$i}{$pieces[$i]}++;
	    $i++;
	}
    }
    close (IN);
    $A= "A";
    $T = "T";
    $C = "C";
    $G = "G";
    foreach $seed (sort keys %polyhash){
	foreach $position (sort {$a <=> $b} keys %{$polyhash{$seed}}){
	    $polyhash{$seed}{$position}{$A} = 0 unless ($polyhash{$seed}{$position}{$A});
	    $polyhash{$seed}{$position}{$T} = 0 unless($polyhash{$seed}{$position}{$T});
	    $polyhash{$seed}{$position}{$C} = 0 unless($polyhash{$seed}{$position}{$C});
	    $polyhash{$seed}{$position}{$G} = 0 unless($polyhash{$seed}{$position}{$G});
	    print "$seed\t$position\t$polyhash{$seed}{$position}{$A}\t$polyhash{$seed}{$position}{$T}\t$polyhash{$seed}{$position}{$C}\t$polyhash{$seed}{$position}{$G}\n";
	}
    }
