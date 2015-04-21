#! /usr/bin/perl -w
#
#

	die "Usage: mat_file abundance_cut-off\n" unless (@ARGV);
	($mat,  $abund) = (@ARGV);

	die "Please follow command line args\n" unless ($abund);
	chomp ($mat);
chomp ($abund);
open (IN, "<$mat") or die "Can't open $mat\n";
while ($line=<IN>){
    chomp ($line);
    ($OTU, @abunds) = split ("\t", $line);
    if (@headers){
	$i=0;
	$j=@headers;
	until ($i>=$j){
	    $hash{$headers[$i]}+=$abunds[$i];
	    $i++;
	}
    } else {
	(@headers)=(@abunds);
    }
}
close (IN);

open (IN, "<$mat") or die "Can't open $mat\n";
while ($line=<IN>){
    chomp ($line);
    ($OTU, @abunds) = split ("\t", $line);
    if (@headers){
	print "$OTU";
	$i=0;
	$j=@abunds;
	until ($i >=$j){
            if ($hash{$headers[$i]}>=$abund){
		print "\t$abunds[$i]";
            }
	    $i++;
	}
	print "\n";
    } else {
	(@headers)=(@abunds);
	print "$OTU";
	$i=0;
	$j=@headers;
	until ($i>=$j){
            if ($hash{$headers[$i]}>=$abund){
                print "\t$headers[$i]";
            }
            $i++;
	}
	print "\n";
    }
}
close (IN);
