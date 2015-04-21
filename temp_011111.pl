#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Get a count of gaps or conserved bases
Usage: <input_file> Redirect output\n" unless (@ARGV);
	
	chomp (@ARGV);
	($file) = (@ARGV);
	$/ = ">";
	open (IN, "<$file") or die "Can't open $file\n";
	while ($line1 = <IN>){	
		chomp ($line1);
		next unless ($line1);
		$sequence = ();
		(@pieces) = split ("\n", $line1);
		($info) = shift (@pieces);
		($sequence) = join ("", @pieces);
		$sequence =~tr/\n//d;
		(@bases) = split ("", $sequence);
		$i=1;
		$total++;
		foreach $base (@bases){
		    $hash{$i}{$base}++;
		    $totalbasehash{$base}++;
		    $i++;
		}
	}
	
	close (IN);

foreach $position (sort {$a <=> $b} keys %hash){
    print "position";
    foreach $base (sort keys %totalbasehash){
	print "\t$base";
    }   
    print "\n";
    last;
}

foreach $position (sort {$a <=> $b} keys %hash){
    print "$position";
    foreach $base (sort keys %totalbasehash){
	if ($hash{$position}{$base}){
	    $percent = 100*$hash{$position}{$base}/$total;
	    print "\t$percent";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}
