#! /usr/bin/perl -w

die "Use this to filter a list an make OTUs from the list
Usage: matfile otulist eco/phylo> redirect\n" unless (@ARGV);

($mat, $otulist, $type)=(@ARGV);
chomp ($mat);
chomp ($otulist);

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
	    $abundhash{$OTU}+=$p[$i];
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
    if ($type eq "phylo"){
	($otunumber, @groups)=split ("\t", $line);
    } elsif ($type eq "eco"){
	(@groups)=split ("\t", $line);
    } else {
	die "I don't recognize the type\n";
    }
    $OTUname=();
    if ($type eq "eco"){
	#find the most abundant sequnece
	foreach $name (@groups){
	    if ($OTUname){
		if ($abundhash{$name}>$abundhash{$OTUname}){
		    $OTUname=$name;
		}
	    } else {
		$OTUname=$name;
	    }
	}
    }
    foreach $name (@groups){
	#now get the overall distribution from the mathash
	if ($type eq "phylo"){
	    $transhash{$name}=$otunumber;
	} elsif ($type eq "eco"){
	    $transhash{$name}=$OTUname;
	}
	foreach $head (@headers){
	    if ($mathashgot{$name}{$head}){
		$finalhash{$transhash{$name}}{$head}+=$mathash{$name}{$head};
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
