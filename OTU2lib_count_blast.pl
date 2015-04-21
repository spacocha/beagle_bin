#! /usr/bin/perl -w
#
#

	die "Use this program to take blast in table for and make OTU counts
The unique sequences should be blasted (i.e. run fasta2unique_table3.pl 
then blastall with the -m 8 option of the .fa output of above (that is the blast file input)
Also, run OTU2lib_count_trans1.pl on the .trans output (that is the mat file input)
Usage: blast mat > Redirect\n" unless (@ARGV);
	($file1, $mat) = (@ARGV);
	die "Please follow command line args\n" unless ($mat);
chomp ($file1);
chomp ($mat);

open (IN, "<${file1}") or die "Can't open ${file1}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    #remove if it was removed at any step of the process
    next if ($line=~/remove/);
    ($name, $OTU)=split ("\t", $line);
    if ($blasthash{$name}){
	die "Please run blast with the -v 1 -b 1 option to remove dulicate blast hits and only retain best blast hit: $name  $blasthash{$name}\n" unless ($blasthash{$name} eq $OTU);
    } else {
	$blasthash{$name}=${OTU};
    }
}
close (IN);

open (IN, "<${mat}") or die "Can't open ${mat}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if (@headers){
	$i=0;
	$j=@pieces;
	until ($i >=$j){
	    if ($blasthash{$OTU}){
		$OTUhash{$blasthash{$OTU}}{$headers[$i]}+=$pieces[$i];
	    } else {
		$OTUhash{$OTU}{$headers[$i]}+=$pieces[$i];
	    }
	    $alllib{$headers[$i]}++;
	    $i++;
	}
    } else {
	(@headers)=@pieces;
    }
}
close (IN);

foreach $OTU (sort keys%OTUhash){
    print "OTU";
    foreach $lib (sort keys %alllib){
	print "\t$lib";
    }
    print "\n";
    last;
}

foreach $OTU (sort keys %OTUhash){
    print "$OTU";
    foreach $lib (sort keys %alllib){
	if ($OTUhash{$OTU}{$lib}){
	    print "\t$OTUhash{$OTU}{$lib}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}
