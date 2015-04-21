#! /usr/bin/perl -w
#
#

	die "Usage: Forward_table Forward_tab Reverse_table Reverse_tab > Redirect\n" unless (@ARGV);
	($file1, $file2, $file3, $file4) = (@ARGV);

	die "Please follow command line args\n" unless ($file4);
chomp ($file1);
chomp ($file2);
chomp ($file3);
chomp ($file4);

	open (IN, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($sol_name, $fastaname)=split ("\t", $line);
		($shrt_name) = $sol_name=~/^(.+\#[A-Z]{7})\//;
		$fhash{$shrt_name}=$fastaname;
       	}
	close (IN);

open (IN, "<$file3") or die "Can't open $file3\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($sol_name, $fastaname)=split ("\t", $line);
    ($shrt_name) = $sol_name=~/^(.+\#[A-Z]{7})\//;
    $rhash{$shrt_name}=$fastaname;
}
close (IN);

open (IN, "<$file2") or die "Can't open $file2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($fastaname, $ref, $id, $per, $gap, $len, $Q)=split ("\t", $line);
    ($newname) = $fastaname =~/^ *(ID.*)$/;
    $fblast{$newname}=$ref;
}
close (IN);

open (IN, "<$file4") or die "Can't open $file4\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($fastaname, $ref, $id, $per, $gap, $len, $Q)=split ("\t", $line);
    ($newname) = $fastaname =~/^ *(ID.*)$/;
    $rblast{$newname}=$ref;
}
close (IN);

foreach $name (keys %fhash){
    next unless ($rhash{$name});
    if ($fblast{$fhash{$name}} && $rblast{$rhash{$name}}){
	if ($fblast{$fhash{$name}} eq $rblast{$rhash{$name}}){
	    $nonchim++;
	} elsif ($fblast{$fhash{$name}} || $rblast{$rhash{$name}}){
	    $chim++;
	}
    }
}

print "Chimera: $chim\nNon-chimera: $nonchim\n";
