#! /usr/bin/perl -w

die "Use this where each line is an OTU and they are named by the first one there (ecoOTU)
Usage: true matfile otulist > redirect\n" unless (@ARGV);

($true, $mat, $otulist)=(@ARGV);
chomp ($mat);
chomp ($true);

open (IN, "<$true" ) or die "Can't open $true\n";
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    $hash{$line}++;
}
close (IN);
open (IN, "<$mat" ) or die "Can't open $mat\n";
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @p)=split ("\t", $line);

    if ($first){
        (@headers)=(@p);
        $first=();
    } else {
        $i=0;
        $j=@p;
        until ($i >=$j){
            $mathash{$OTU}{$headers[$i]}=$p[$i];
	    $mathashgot{$OTU}{$headers[$i]}++;
            $i++;
        }
    }
}
close (IN);

open (IN, "<$otulist" ) or die "Can't open $otulist\n";
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@groups)=split ("\t", $line);
    (@groups2)=@groups;
    $OTUname=();
    foreach $name (@groups){
	if ($hash{$name}){
	    #it's a true OTU and call it by that name
	    $OTUname=$name;
	}
    }
    ($OTUname)=shift(@groups2) unless ($OTUname);
    foreach $name (@groups){
	#now get the overall distribution from the mathash
	foreach $head (@headers){
	    if ($mathashgot{$name}{$head}){
		$finalhash{$OTUname}{$head}+=$mathash{$name}{$head};
	    } else {
		die "Missing $name from mathash\n";
	    }
	}
    }
}
close (IN);

print "OTU";
foreach $head (@headers){
    print "\t$head";
}
print "\n";

foreach $OTU (sort keys %finalhash){
    print "$OTU";
    foreach $head (@headers){
	print "\t$finalhash{$OTU}{$head}";
    }
    print "\n";
}
