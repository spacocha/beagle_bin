#! /usr/bin/perl -w
#
#

	die "Usage: blast_report_tab UC_count > Redirect\n" unless (@ARGV);
	($file1, $file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file1);
chomp ($file2);

open (IN, "<$file2") or die "Can't open $file2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($seed, $count)=split ("\t", $line);
    $counthash{$seed}=$count;
}
close (IN);

open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($fastaname, $ref, $id, $per, $gap, $len, $Q)=split ("\t", $line);
    ($newname, $num) = $fastaname =~/^ *[0-9]+\|\*\|(.+)_([1234])$/;
    $fblast{$newname}{$num}=$ref;
}
close (IN);

$one = 1;
$two = 2;
foreach $name (sort {$counthash{$b} <=> $counthash{$a}} keys %counthash){
    die "Not working $name\n" unless ($fblast{$name});
    if ($fblast{$name}{$one} && $fblast{$name}{$two}){
	if ($fblast{$name}{$one} eq $fblast{$name}{$two}){
	    print "$name\t$fblast{$name}{$one}\t$fblast{$name}{$two}\tNon-chimeric\t$counthash{$name}\n";
	} else {
	    print "$name\t$fblast{$name}{$one}\t$fblast{$name}{$two}\tChimeric\t$counthash{$name}\n";
	}
    } else {
	$fblast{$name}{$one} = "NA" unless ($fblast{$name}{$one});
	$fblast{$name}{$two} = "NA" unless ($fblast{$name}{$two});
	print "$name\t$fblast{$name}{$one}\t$fblast{$name}{$two}\tNon-mock/Poor Quality\t$counthash{$name}\n";
    }
}
