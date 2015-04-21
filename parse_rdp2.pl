#! /usr/bin/perl -w
#
#

	die "Usage: RDP_file lib_count output\n" unless (@ARGV);
	($file2, $file3, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file3);
chomp ($file2);
chomp ($output);

open (IN, "<$file3") or die "Can't open $file3\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @libs)=split ("\t", $line);
    if ($headers){
	$i=1;
	foreach $library (@libs){
	    $counthash{$name}{$i}=$library;
	    $complete{$i}+=$library;
	    $i++;

	}
    } else {
	$i=1;
	$headers++;
	foreach $library (@libs){
	    $namehash{$i}=$library;
	    $i++;
	}
    }

}
close (IN);

$/=">";

open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, $rdp)=split ("\n", $line);
		($shrtname) = $name =~/^(.+_con)_[0-9]+/;
		(@seqs) = split (";", $rdp);
		$i=0;
		$conclass = ();
		$j = @seqs;
		until ($i > $j){
		    if ($conclass){
			$conclass = "$conclass"."_"."$seqs[$i]";
		    } else {
			$conclass = $seqs[$i];
		    }
		    $i+=2;
		}
		    
		push (@{$hash{$conclass}}, $shrtname);

       	}
close (IN);

open (OUT, ">${output}.group") or die "Can't open ${output}.group\n";
open (OUT2, ">${output}.total") or die "Can't open ${output}.total\n";
$tabcount=1;
print OUT2 "CONCLASS\tTABCOUNT";
foreach $lib (sort keys %namehash){
    print OUT2 "\t$namehash{$lib}";
}
print OUT2 "\n";

foreach $conclass (keys %hash){
    print OUT "$conclass\t$tabcount";
    foreach $name (@{$hash{$conclass}}){
	print OUT "\t$name";
	foreach $lib (sort keys %{$counthash{$name}}){
	    $totalcount{$conclass}{$lib}+=$counthash{$name}{$lib};
	}
    }
    print OUT "\n";

    print OUT2 "$conclass\t$tabcount";
    foreach $lib (sort keys %namehash){
	if ($totalcount{$conclass}{$lib}){
	    $percent = 100*$totalcount{$conclass}{$lib}/$complete{$lib};
	    print OUT2 "\t$percent";
	} else {
	    print OUT2 "\t0";
	}
    }

    print OUT2 "\n";
    $tabcount++;
}

close (OUT);
close (OUT2);
