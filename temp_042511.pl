#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: <input_file> output\n" unless (@ARGV);
	
	chomp (@ARGV);
	($file, $output) = (@ARGV);
	open (IN, "<$file") or die "Can't open $file\n";
open (OUT1, ">${output}.gis") or die "Can't open ${output}.gis\n";
open (OUT2, ">${output}.trans") or die "Can't open ${output}.trans\n";
	while ($line1 = <IN>){	
		chomp ($line1);
		next unless ($line1);
		$sequence = ();
		($query, $hit, $per, $num, $mis, $gap, $tot, $num2, $num3, $num4, $exp, $bla) = split ("\t", $line1);
		if ($bestblast{$query}){
		    if ($exp == $bestblast{$query}){
			#best blast
			$blasthash{$query}{$hit}{'exp'}=$exp;
			$blasthash{$query}{$hit}{'mis'}=$mis;
			$blasthash{$query}{$hit}{'gap'}=$gap;
			$blasthash{$query}{$hit}{'tot'}=$tot;
			$blasthash{$query}{$hit}{'num2'}=$num2;
			$blasthash{$query}{$hit}{'num3'}=$num3;
			$blasthash{$query}{$hit}{'num4'}=$num4;
			$blasthash{$query}{$hit}{'bla'}=$bla;
			($ginum)=$hit=~/gi\|([0-9]+?)\|/;
			print OUT1 "$ginum\n";
			print OUT2 "$query\t$ginum\n";
		    }
		} else{
		    #same as best blast
		    $bestblast{$query}=$exp;
		    $blasthash{$query}{$hit}{'exp'}=$exp;
                    $blasthash{$query}{$hit}{'mis'}=$mis;
                    $blasthash{$query}{$hit}{'gap'}=$gap;
                    $blasthash{$query}{$hit}{'tot'}=$tot;
                    $blasthash{$query}{$hit}{'num2'}=$num2;
                    $blasthash{$query}{$hit}{'num3'}=$num3;
                    $blasthash{$query}{$hit}{'num4'}=$num4;
		    $blasthash{$query}{$hit}{'bla'}=$bla;
                    ($ginum)=$hit=~/gi\|([0-9]+?)\|/;
                    print OUT1 "$ginum\n";
		    print OUT2 "$query\t$ginum\n";
		}
	}
	
	close (IN);
close (OUT1);
close (OUT2);
