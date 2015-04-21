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
		($query, $hit, $per, $num, $mis, $gap, $qstart, $qend, $sstart, $send, $exp, $bla) = split ("\t", $line1);
		if ($bestblast{$query}){
		    if ($exp == $bestblast{$query}){
			#same as best blast
			$blasthash{$query}{$hit}{'exp'}=$exp;
			$blasthash{$query}{$hit}{'mis'}=$mis;
			$blasthash{$query}{$hit}{'gap'}=$gap;
			$blasthash{$query}{$hit}{'tot'}=$tot;
			$blasthash{$query}{$hit}{'num2'}=$num2;
			$blasthash{$query}{$hit}{'num3'}=$num3;
			$blasthash{$query}{$hit}{'num4'}=$num4;
			$blasthash{$query}{$hit}{'bla'}=$bla;
			($ginum)=$hit=~/gi\|([0-9]+?)\|/;
			if ($giprinthash{$ginum}){
			    #it was already printed
			} else {
			    print OUT1 "$ginum\n";
			    $giprinthash{$ginum}++;
			}
			print OUT2 "$query\t$ginum\t$per\t$num\t$mis\t$gap\t$qstart\t$qend\t$sstart\t$send\t$exp\t$bla\n";
		    }
		} else{
		    #best blast
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
		    if ($giprinthash{$ginum}){
			#it was already printed
		    } else {
			print OUT1 "$ginum\n";
			$giprinthash{$ginum}++;
		    }
		    print OUT2 "$query\t$ginum\t$per\t$num\t$mis\t$gap\t$qstart\t$qend\t$sstart\t$send\t$exp\t$bla\n";

		}
	}
	
	close (IN);
close (OUT1);
close (OUT2);
