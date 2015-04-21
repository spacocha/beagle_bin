#! /usr/bin/perl -w

die "Use this to filter a list an make OTUs from the list
Usage: matfile otulist eco/phylo/mothur > redirect\n" unless (@ARGV);

($mat, $otulist, $type)=(@ARGV);
chomp ($mat);
chomp ($otulist);
chomp ($type);

die "Please follow command line arg\n" unless ($type);

open (IN, "<$mat" ) or die "Can't open $mat\n";
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($oldOTU, @p)=split ("\t", $line);
    if ($oldOTU=~/^(ID.+M)/){
	($OTU)=$oldOTU=~/^(ID.+M)/;
    } else {
	$OTU=$oldOTU;
    }
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
    } elsif ($type eq "mothur"){
	($otunumber, $groupline)=split ("\t", $line);
	(@groups)=split (",", $groupline);
    } else {
	die "I don't recognize the type\n";
    }
    foreach $oldname (@groups){
	if ($oldname=~/^(ID.+M)/){
	    ($name)=$oldname=~/^(ID.+M)/;
	} else {
	    $name=$oldname;
	}
	unless ($done{$name}){
	    #now get the overall distribution from the mathash
	    foreach $head (@headers){
		if ($mathashgot{$name}{$head}){
		    $finalhash{$otunumber}{$head}+=$mathash{$name}{$head};
		} else {
		    die "Missing $name from mathash\n";
		}
	    }
	    $done{$name}++;
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
