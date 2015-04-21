#! /usr/bin/perl -w
#
#

	die "Usage: mat lib_count_min> redirect\n" unless (@ARGV);
	($file1, $libmin) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1, $libmin);
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
	    #sum up the total for each header value (library)
	    #+= value means you add the amount of vals[$i] to the total for each header
	    $totalhash{$headers[$i]}+=$vals[$i];
	    $i++;
	}
    }
    
}
close (IN);
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
	print "$line\n";
    } else {
        #using an index to compare header values with vals values               
	print "$info";
	$i=0;
        $j=@vals;
        until ($i >=$j){	
	    if ($vals[$i]){
		if ($totalhash{$headers[$i]}){
		    #make the value into the fraction of total counts in the library
		    $fraction=$vals[$i]/$totalhash{$headers[$i]};
		    #print out value as fraction instead of count
		    print "\t$fraction";
		} else {
		    die "Missing $headers[$i] total $totalhash{$headers[$i]}\n";
		}
	    } else {
		print "\t0";
	    }
	    $i++;
	}
	print "\n";
    }
}
close (IN);

print "Total";
$i=0;
$j=@headers;
until ($i>=$j){
    print "\t$totalhash{$headers[$i]}";
    $i++;
}
print "\n";
