#! /usr/bin/perl -w
#
#

	die "Usage: mat > redirect\n" unless (@ARGV);
	($file1) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
$first=1;
open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @vals)=split ("\t", $line);
    if ($first){
	#make the first line the headers
	$first=0;
	(@headers)=@vals;
    } else{
	#using an index to compare header values with vals values
	$i=0;
	$j=@vals;
	until ($i >=$j){
	    #record the value for each info (OTU) and header (library)
	    $hash{$info}{$headers[$i]}=$vals[$i];
	    #sum up the total for each header value (library)
	    #+= value means you add the amount of vals[$i] to the total for each header
	    $totalhash{$headers[$i]}+=$vals[$i];
	    $i++;
	}
    }

}

#print out values
foreach $info (sort keys %hash){
    #makes the first row
    print "Info";
    foreach $header (sort keys %{$hash{$info}}){
        if ($totalhash{$header}){
            $fraction=$hash{$info}{$header}/$totalhash{$header};
            print "\t$header";
	}
    }
    print "\n";
    #exit loop once first line headers are printed
    last;
}

#now calculate and record values for each OTU
foreach $info (sort keys %hash){
    #print OTU name
    print "$info";
    #go through each header
    foreach $header (sort keys %{$hash{$info}}){
	#each header needs to have some value otherwise there's really no reason to print an empty column
	if ($totalhash{$header}){
	    #make the value into the fraction of total counts in the library
	    $fraction=$hash{$info}{$header}/$totalhash{$header};
	    #print out value as fraction instead of count
	    print "\t$fraction";
	}
    }
    print "\n";
}

foreach $info (sort keys %hash){
    print "TotalCounts";
    foreach $header (sort keys %{$hash{$info}}){
	if ($totalhash{$header}){
	    print "\t$totalhash{$header}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
    last;
}
