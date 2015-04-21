#! /usr/bin/perl -w
#
#

die "Usage: mat_lin output_prefix\n" unless (@ARGV);
($mat, $output) = (@ARGV);

die "Please follow command line args\n" unless ($mat);
chomp ($mat);
$first=1;
open (IN, "<$mat") or die "Can't open $mat\n";
while ($line=<IN>){
    chomp ($line);
    ($OTU, @abunds) = split ("\t", $line);
    ($lin)=pop(@abunds);
    if ($first){
	$first=();
	@headers=@abunds;
	$linhead=$lin;
    } else {
	if ($lin=~/^k__(.*);p__(.*);c__(.*);o__(.*);f__(.*);g__(.*);s__(.*)$/){
	    ($king, $phylum, $class, $order, $family, $genus, $species)=$lin=~/^k__(.*);p__(.*);c__(.*);o__(.*);f__(.*);g__(.*);s__(.*)$/;
	} else {
	    die "$lin doesn't fit regex\n";
	}
	$class="NA" unless ($class);
	$genus="NA" unless ($genus);
	$i=0;
	$j=@abunds;
	until ($i >=$j){
	    $classhash{$class}{$headers[$i]}+=$abunds[$i];
	    $genushash{$genus}{$headers[$i]}+=$abunds[$i];
	    $allhead{$headers[$i]}++;
	    $i++;
	}
    }
}
close (IN);

open (CLASS, ">${output}.class.txt") or die "Can't open ${output}.class.txt\n";
print CLASS "OTU";
foreach $head (sort keys %allhead){
    print CLASS "\t$head";
}
print CLASS "\n";

foreach $class (sort keys %classhash){
    print CLASS "$class";
    foreach $head (sort keys %allhead){
	if ($classhash{$class}{$head}){
	    print CLASS "\t$classhash{$class}{$head}";
	} else {
	    print CLASS "\t0";
	}
    }
    print CLASS "\n";
}
close (CLASS);

open (GENUS, ">${output}.genus.txt") or die "Can't open ${output}.genus.txt\n";

print GENUS "OTU";
foreach $head (sort keys %allhead){
    print GENUS "\t$head";
}
print GENUS "\n";

foreach $genus (sort keys %genushash){
    print GENUS "$genus";
    foreach $head (sort keys %allhead){
        if ($genushash{$genus}{$head}){
            print GENUS "\t$genushash{$genus}{$head}";
	} else {
            print GENUS "\t0";
}
    }
    print GENUS "\n";
}
close (GENUS);
