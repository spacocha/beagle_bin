#! /usr/bin/perl -w
#
#

	die "Usage: RDP_file output\n" unless (@ARGV);
	($file2, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);

chomp ($file2);

$/=">";

open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, $rdp)=split ("\n", $line);
		($count) = $name =~/_([0-9]+) reverse/;
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
		    
		push (@{$hash{$conclass}}, $name);
		$counthash{$name}=$count;
       	}
close (IN);

open (OUT, ">${output}.group") or die "Can't open ${output}.group\n";
open (OUT2, ">${output}.total") or die "Can't open ${output}.total\n";
$tabcount=1;
foreach $conclass (keys %hash){
    $totalcount=0;
    foreach $name (@{$hash{$conclass}}){
	$totalcount+=$counthash{$name};
	print OUT "$tabcount\t$name\t$counthash{$name}\n";
    }
    @seqs = split ("_", $conclass);
    print OUT2 "Seed $tabcount\t$totalcount";
    foreach $class (@seqs){
	print OUT2 "\t$class";
    }
    print OUT2 "\n";
    $tabcount++;
}

close (OUT);
close (OUT2);
