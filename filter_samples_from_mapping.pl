#! /usr/bin/perl -w
#
#

	die "Usage: mat_file map prefix\n" unless (@ARGV);
	($mat,  $map, $prefix) = (@ARGV);

	die "Please follow command line args\n" unless ($prefix);
	chomp ($mat);
chomp ($abund);
chomp ($prefix);

open (IN, "<$map") or die "Can't open $map\n";
while ($line=<IN>){
    chomp ($line);
    ($OTU, @abunds) = split ("\t", $line);
    $inmap{$OTU}=$line;
}
close (IN);

open (OUT, ">${prefix}.mat") or die "Can't open ${prefix}.mat\n";
open (IN, "<$mat") or die "Can't open $mat\n";
while ($line=<IN>){
    chomp ($line);
    ($OTU, @abunds) = split ("\t", $line);
    if (@headers){
	print OUT "$OTU";
	$i=0;
	$j=@abunds;
	until ($i >=$j){
            if ($inmap{$headers[$i]}){
		print OUT "\t$abunds[$i]";
            }
	    $i++;
	}
	print OUT "\n";
    } else {
	(@headers)=(@abunds);
	print OUT "$OTU";
	$i=0;
	$j=@headers;
	until ($i>=$j){
            if ($inmap{$headers[$i]}){
		$done{$headers[$i]}++;
                print OUT "\t$headers[$i]";
            }
	    $i++;
	}
	print OUT "\n";
    }
}
close (IN);
close (OUT);

$first="#SampleID";
open (OUT, ">${prefix}.map") or die "Can't open ${prefix}.map\n";
print OUT "$inmap{$first}\n";
foreach $sample (sort keys %done){
    print OUT "$inmap{$sample}\n";
}
close (OUT);
