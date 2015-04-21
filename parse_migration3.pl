#! /usr/bin/perl -w
#
#

	die "Use this file to parse migration.matrix into excel format
USAGE: migration.matrix > Redirect\n" unless (@ARGV);

($file)= (@ARGV);
open (IN, "<${file}") or die "Can't open $file\n";
while ($line=<IN>){
	chomp ($line);
	($newline1) = $line=~/^\{(.+)\}$/;
	$newline1=~s/habitat 0/habitat 9999/g;
	$newline="$newline1".",";
	(@habitats)= split ("habitat", $newline);
	foreach $piece (@habitats){
		($habno) = $piece=~/^ ([0-9]{1,4})':/;
		next unless ($habno);
		(@parts)=split ("{", $piece);
		(@comps) =$parts[1]=~/\'([A-Z]*[1-9]*[A-Z]+': .+?),/g;
		foreach $set (@comps){
			($habname, $percent)=$set=~/^(.+)\': (.+)$/;
			$percent=~tr/\}//d;
			
			$hash{$habname}{$habno}=$percent;
#			print "$habname\t$habno\t$percent\n";
		}
	}
}
close (IN);
$print = 1;
foreach $habname (sort keys %hash){
	foreach $habno (sort keys %{$hash{$habname}}){ 
		print "\t$habno" if ($print);
	}
	print "\n" if ($print);
	$print=0;
}
foreach $habname (sort keys %hash){
	print "$habname";
	foreach $habno (sort keys %{$hash{$habname}}){ 
		
		print "\t$hash{$habname}{$habno}";
	}
	print "\n";
}
	
