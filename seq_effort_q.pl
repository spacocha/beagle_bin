#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: <input_file> Redirect output\n" unless (@ARGV);
	
	chomp (@ARGV);
	($file) = (@ARGV);
	$/ = ">";
	open (IN, "<$file") or die "Can't open $file\n";
	while ($line1 = <IN>){	
		chomp ($line1);
		next unless ($line1);
		(@pieces) = split ("\n", $line1);
		($info) = shift (@pieces);
		($sample)=$info=~/^sample=(.+);[0-9]+\/[0-9]+$/;
		if ($sample=~/^M/){
		    $date="8.2008";
		    if ($sample=~/^M[0-9]+$/){
			$depth1=$sample=~/^M([0-9]+)$/;
			$depth="$depth1"."m";
		    } else {
			$depth=$sample;
		    }
		} elsif ($sample=~/^.+\.[0-9]+\.[0-9]+\.[0-9]+$/){
		    ($depth, $date)=$sample=~/^(.+)\.([0-9]+\.[0-9]+\.[0-9]+$)/;
		} elsif ($sample=~/^.+_[0-9]+\.[0-9]+\.[0-9]+$/){
		    ($depth, $date)=$sample=~/^(.+)_([0-9]+\.[0-9]+\.[0-9]+)$/;
		} elsif ($sample=~/^[0-9]+\.[0-9]+\.[0-9]+_.+$/){
		    ($date, $depth)=$sample=~/^([0-9]+\.[0-9]+\.[0-9]+)_(.+)$/;
		} elsif ($sample=~/^.+\.[0-9]+\.[0-9]{4}$/){
		    ($depth, $date)=$sample=~/^(.+)\.([0-9]+\.[0-9]{4})$/;
		} elsif ($sample=~/^[0-9]+\.[0-9]{4}_.+$/){
		    ($date, $depth)=$sample=~/^([0-9]+\.[0-9]{4})_(.+)$/;
		} elsif ($sample=~/^.+_[0-9]+\.[0-9]+\.[0-9]+_.+$/){
		    ($depth, $date)=$sample=~/^(.+)_([0-9]+\.[0-9]+\.[0-9]+)_.+$/;
		} else {
		    $date = "Unknown";
		    $depth=$sample;
		}		
		die "Depth:$depth\tDate:$date\tsample:$sample\n" unless ($depth && $date && $sample);
		$hash{$depth}{$date}++;
		$alldates{$date}++;

	}
	
	close (IN);

	
print "Sample";
foreach $date (sort keys %alldates){
    print "\t$date";
}
print "\n";

foreach $depth (sort keys %hash){
    print "$depth";
    foreach $date (sort keys %alldates){
	if ($hash{$depth}{$date}){
	    print "\t$hash{$depth}{$date}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}
