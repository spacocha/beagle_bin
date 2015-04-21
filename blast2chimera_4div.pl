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
$three = 3; 
$four = 4;
foreach $name (keys %fblast){
    die "Not working $name\n" unless ($counthash{$name});
    if ($fblast{$name}{$one} && $fblast{$name}{$two} && $fblast{$name}{$three} && $fblast{$name}{$four}){
	if ($fblast{$name}{$one} eq $fblast{$name}{$two} && $fblast{$name}{$three} eq $fblast{$name}{$four} && $fblast{$name}{$one} eq $fblast{$name}{$four}){
	    print "$name\t$fblast{$name}{$one}\t$fblast{$name}{$two}\t$fblast{$name}{$three}\t$fblast{$name}{$four}\tNon-chimeric\t$counthash{$name}\n";
	} else {
	    print "$name\t$fblast{$name}{$one}\t$fblast{$name}{$two}\t$fblast{$name}{$three}\t$fblast{$name}{$four}\tChimeric\t$counthash{$name}\n";
	}
    } else {
	$fblast{$name}{$one} = "NA" unless ($fblast{$name}{$one});
	$fblast{$name}{$two} = "NA" unless ($fblast{$name}{$two});
	$fblast{$name}{$three} = "NA" unless ($fblast{$name}{$three});
	$fblast{$name}{$four} = "NA" unless ($fblast{$name}{$four});
	print "$name\t$fblast{$name}{$one}\t$fblast{$name}{$two}\t$fblast{$name}{$three}\t$fblast{$name}{$four}\tPoor Quality\t$counthash{$name}\n";
    }
}
