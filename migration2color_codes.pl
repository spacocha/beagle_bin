#! /usr/bin/perl -w
#
#
	die "Use this to make color codes from the migration files
USAGE: <migration file> <color file> > Redirect\n" unless (@ARGV);

($file, $color) = (@ARGV);
chomp ($file);
open (IN, "<${file}") or die "Can't open $file\n";
while ($line=<IN>){
	chomp ($line);
	next unless ($line);
	@habno = $line=~/'habitat *([0-9]{1,3})'/g;
	@codes = $line=~/'([A-z][A-z][A-z])'/g;
	foreach $code (@codes){
		(@pieces) = split ("", $code);
		$index=0;
		foreach $piece (@pieces){
			$spot=$index+1;
			$codehash{$spot}{$piece}++;
			$index++;
		}
	}

}

close (IN);
open (IN, "<${color}") or die "Can't open $color\n";
$place=1;
while ($line=<IN>){
	chomp($line);
	next unless ($line);
	$colors{$place}="$line";
	$place++;
}
close (IN);

$place=1;
	foreach $spot (keys %codehash){
		foreach $piece (keys %{$codehash{$spot}}){
			print "$spot $piece $colors{$place}\n";
			$place++;
		}
	}

	
	foreach $hab (@habno){
		print "H $hab $colors{$place}\n";
		$place++;
	}

