#! /usr/bin/perl -w
#
#

	die "Use this file with a .dst file from clustal to get a 
pairwise tab del output for 1 isolate 2 isolate dist
Usage: <inputfile> > Redirect\n" unless (@ARGV);
	($file) = (@ARGV);
	chomp ($file);
$first=1;
	open (IN, "<$file") or die "Can't open $file\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		(@pieces) = split (" ", $line);
		if ($first){
		    $totalno=$line;
		    $totalno=~s/ //g;
		    $first=();
		    $gotten=0;
		    $gicount=0;
		} else {
		    #have you already started with a gi?
		    if ($gi){
			#is this the end of the file?
			if ($gotten >= $totalno){
			    #start over
			    ($gi)=shift(@pieces);
			    $gicount++;
			    $gicounthash{$gicount}=$gi;
			    $gotten=0;
			    foreach $piece (@pieces){
				$gotten++;
				$datahash{$gicount}{$gotten}=$piece;
			    }
			} else {
			    foreach $piece (@pieces){
                                $gotten++;
                                $datahash{$gicount}{$gotten}=$piece;
                            }
			}
		    } else {
			#first get the gi
			($gi)=shift(@pieces);
			$gicount++;
			$gicounthash{$gicount}=$gi;
			#die"GI First:$gi\n";
			foreach $piece (@pieces){
			    $gotten++;
			    $datahash{$gicount}{$gotten}=$piece;
			}
		    }
		}

	    }
foreach $gi (sort keys %datahash){
    foreach $othergi (sort keys %datahash){
	next if ($gi== $othergi);
	next if ($done{$gi}{$othergi});
	$done{$gi}{$othergi}++;
	$done{$othergi}{$gi}++;
	print "$gicounthash{$gi}\t$gicounthash{$othergi}\t$datahash{$gi}{$othergi}\n";
    }
}
