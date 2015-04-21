#! /usr/bin/perl -w

die "Usage: eOTU_list1 phylo_list2 mat> redirect\n" unless (@ARGV);

($list1, $list2, $mat)=(@ARGV);
chomp ($list1, $list2, $mat);

#get abundances from the mat file
open (IN, "<$mat" ) or die "Can't open $mat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @vals)=split ("\t", $line);
    if (@headers){
	foreach $value (@vals){
	    $abundhash{$OTU}+=$value;
	}
    } else {
	(@headers)=@vals;
    }
}
close (IN);

open (IN, "<$list1" ) or die "Can't open $list1\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@OTUs)=split ("\t", $line);
    ($name)=$OTUs[0];
    foreach $OTU (@OTUs){
	$list1hash{$OTU}=$name;
	$list1comp{$name}{$OTU}++;
    }
}
close (IN);

open (IN, "<$list2" ) or die "Can't open $list2\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @OTUs)=split ("\t", $line);
    foreach $OTU (@OTUs){
	$list2hash{$OTU}=$name;
        $list2comp{$name}{$OTU}++;
    }
}
close (IN);

#are abundant OTUs in list2 split in list1?
foreach $name (sort keys %list2comp){
    print "Working on name $name how many different eOTU clusters are represented\n";
    %chash=();
    %highabundc=();
    foreach $OTU (sort keys %{$list2comp{$name}}){
	if ($abundhash{$OTU}){
	    if ($list1hash{$OTU}){
		$chash{$list1hash{$OTU}}++;
		if ($abundhash{$OTU}>100){
		    $highabundc{$OTU}++;
		}
	    } else {
		die "Doesn't have a list1hash $list1hash{$OTU}\n";
	    }
	} else {
	    die "No abundance $OTU\n";
	}
    }
    print "$name";
    $total=0;
    $string=();
    foreach $cluster (sort keys %highabundc){
	if ($string){
	    $string="$string"."\t"."$cluster"."_"."$abundhash{$cluster}";
	} else {
	    $string = "\t"."$cluster"."_"."$abundhash{$cluster}";
	}
	$total++;
    }
    print "\t$total$string\n";
}

