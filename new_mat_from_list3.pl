#! /usr/bin/perl -w

die "Use this to filter a list an make OTUs from the list
Usage: matfile otulist eco/phylo/mothur output\n" unless (@ARGV);

($mat, $otulist, $type, $output)=(@ARGV);
chomp ($mat);
chomp ($otulist);
chomp ($type);
chomp ($output);

die "Please follow command line arg\n" unless ($output);

open (OUT, ">${output}.mat") or die "Can't open ${output}.mat\n";
open (LOG, ">${output}.log") or die "Can't open ${output}.log\n";

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
    if ($type eq "eco" || $type eq "phylo"){
	(@groups)=split ("\t", $line);
    } elsif ($type eq "mothur"){
	($otunumber, $groupline)=split ("\t", $line);
	(@groups)=split (",", $groupline);
    } else {
	die "I don't recognize the type\n";
    }
    $OTUname=();
    $mostabund=();
    foreach $oldname (@groups){
	if ($oldname=~/(ID.+M)/){
	    ($name)=$oldname=~/(ID.+M)/;
	} else {
	    $name=$oldname;
	}
	if ($mostabund){
	    #call the OTU by the most abudant name
	    die "name $name abund $abundhash{$name} most $mostabund\n";
	    if ($abundhash{$name}>$mostabund){
		$OTUname=$name;
		$mostabund=$abundhash{$name};
	    }
	} else {
	    $mostabund=$abundhash{$name};
	    $OTUname=$name;
	}
    }
    if ($type eq "phylo"){
	$transhash{$OTUname}=$OTUname;
    } elsif ($type eq "eco"){
	$transhash{$OTUname}=$OTUname;
    }
    foreach $oldname (@groups){
	if ($oldname=~/^(ID.+M)/){
	    ($name)=$oldname=~/^(ID.+M)/;
	} else {
	    $name=$oldname;
	}
	#now get the overall distribution from the mathash
	foreach $head (@headers){
	    if ($mathashgot{$name}{$head}){
		$finalhash{$transhash{$OTUname}}{$head}+=$mathash{$name}{$head};
	    } else {
		print LOG "Missing $name from mathash\n";
	    }
	}
    }
}
close (IN);

print OUT "OTU";
foreach $head (@headers){
    print OUT "\t$head";
}
print OUT "\n";

foreach $OTU (sort keys %finalhash){
    print OUT "$OTU";
    foreach $head (@headers){
	print OUT "\t$finalhash{$OTU}{$head}";
    }
    print OUT "\n";
}
