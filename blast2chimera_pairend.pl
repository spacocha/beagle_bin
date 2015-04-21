#! /usr/bin/perl -w
#
#

	die "Usage: blast_report_F_tab blast_report_R_tab UC_count_f UC_count_r > Redirect\n" unless (@ARGV);
	($file1, $file2, $count1, $count2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file1);
chomp ($file2);
chomp ($count1);
chomp ($count2);


#fix this
open (IN, "<$count1") or die "Can't open $count1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($seq, $seed)=split ("\t", $line);
    $seedhash1{$seq}=$seed;
}
close (IN);

#fix this
open (IN, "<$count2") or die "Can't open $count2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($seq, $seed)=split ("\t", $line);
    $seedhash2{$seq}=$seed;
}
close (IN);

foreach $seq (keys %seedhash1){
    die "Missing half $seq\n"  unless ($seedhash2{$seq});
    #I don't really need to know how each seq functions, just each cluster pair
    #count the total number of occurrences of each cluster pair
    $clpair{$seedhash1{$seq}}{$seedhash2{$seq}}++;
}


open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($fastaname, $ref, $id, $per, $gap, $len, $Q)=split ("\t", $line);
    ($newname, $num) = $fastaname =~/^ *[0-9]+\|\*\|(.+)_([12])$/;
    #store the best blast hit
    $bestrefname1{$newname}{$num}=$ref unless ($bestrefname1{$newname}{$num});
    ($hit, $total, $percent) = $id =~/^([0-9]+)\/([0-9]+) \(([0-9]+)\%\)/;
    die unless ($hit);
    #also store the best blast hit total matches
    $bestref1{$newname}{$num}=$hit unless ($bestref1{$newname}{$num});
    $bestref1m1{$newname}{$num}=$bestref1{$newname}{$num}-1;

    $fblasthit{$newname}{$num}{$ref}=$hit if ($hit >= $bestref1m1{$newname}{$num});
    #fblasthit now only has the equivelent to best blast hits
}
close (IN);

open (IN, "<$file2") or die "Can't open $file2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($seedname, $ref, $id, $per, $gap, $len, $Q)=split ("\t", $line);
    ($newname) = $seedname =~/[0-9]+\|\*\|(.+)$/;
    ($hit, $total, $percent) = $id =~/^([0-9]+)\/([0-9]+) \(([0-9]+)\%\)/;
    $bestrefname2{$newname}=$ref unless ($bestrefname2{$newname});
    $bestref2{$newname}=$hit unless ($bestref2{$newname});
    $bestref2m1{$newname}=$bestref2{$newname}-1;
    die unless ($hit);
    $rblasthit{$newname}{$ref}=$hit if ($hit >= $bestref2m1{$newname});

}
close (IN);

$one = 1;
$two = 2;
foreach $fblastname (keys %clpair){
    foreach $rblastname (keys %{$clpair{$fblastname}}){
    if (%{$fblasthit{$fblastname}{$one}} && %{$fblasthit{$fblastname}{$two}} && %{$rblasthit{$rblastname}}){
	#if there is a blast report for all of the pieces
	$done = ();
	foreach $ref (sort {$fblasthit{$fblastname}{$one}{$b} <=> $fblasthit{$fblastname}{$one}{$a}} keys %{$fblasthit{$fblastname}{$one}}){
	    if ($fblasthit{$fblastname}{$two}{$ref} && $rblasthit{$rblastname}{$ref}){
		#this ref is in all the blast reports, so it's not chimera
		die "WHAT! $ref\n" unless ($rblasthit{$rblastname}{$ref});
		print "$fblastname\t$ref\t$fblasthit{$fblastname}{$one}{$ref}\t$ref\t$fblasthit{$fblastname}{$two}{$ref}\t$rblastname\t$ref\t$rblasthit{$rblastname}{$ref}\tNon-Chimeric\t$clpair{$fblastname}{$rblastname}\t" unless ($done);
		$totalnonchimera+=$clpair{$fblastname}{$rblastname} unless ($done);
		if ($fblastname=~/^HWI-/){
		    print "Non-mock\n" unless ($done);
		} else {
		    #count all the added seqs that map to the forward read as mock
		    $mockname{$fblastname}+=$clpair{$fblastname}{$rblastname} unless ($done);
		    $inmock+=$clpair{$fblastname}{$rblastname} unless ($done);
		    print "In mock\n" unless ($done);
		}
		#only print this once, if you print, exit loop
		$seedhash{$ref}++ unless ($done);
		$done++;
		last;
	    }
	}
	#if you made it through without printing, it's a chimera so print it
	unless ($done){
	    #now just print the best blast from those
	    $fb1name = ();
	    $fb1no = ();
	    $fb2name = ();
	    $fb2no = ();
	    $fb3name = ();
	    $fb3no = ();
	    foreach $ref (keys %seedhash){
		#if there was a ref already printed, keep using that
		if ($fblasthit{$fblastname}{$one}{$ref}){
		    $fb1no = $fblasthit{$fblastname}{$one}{$ref} unless ($fb1no);
		    $fb1name = $ref unless ($fb1name);
		}
                if ($fblasthit{$fblastname}{$two}{$ref}){
                    $fb2no = $fblasthit{$fblastname}{$two}{$ref} unless ($fb2no);
                    $fb2name = $ref unless ($fb2name);
		}
                if ($rblasthit{$rblastname}{$ref}){
                    $fb3no = $rblasthit{$rblastname}{$ref} unless ($fb3no);
                    $fb3name = $ref unless ($fb3name);
		}
	    }
	    unless ($fb1name){
		foreach $ref (sort {$fblasthit{$fblastname}{$one}{$b} <=> $fblasthit{$fblastname}{$one}{$a}} keys %{$fblasthit{$fblastname}{$one}}){
		    $fb1name = $ref;
		    $fb1no = $fblasthit{$fblastname}{$one}{$ref};
		    last;
		}
	    }
            unless ($fb2name){
		foreach $ref (sort {$fblasthit{$fblastname}{$two}{$b} <=> $fblasthit{$fblastname}{$two}{$a}} keys %{$fblasthit{$fblastname}{$two}}){
                    $fb2name = $ref;
                    $fb2no = $fblasthit{$fblastname}{$two}{$ref};
                    last;
                }
	    }  
            unless ($fb3name){
		foreach $ref (sort {$rblasthit{$rblastname}{$b} <=> $rblasthit{$rblastname}{$a}} keys %{$rblasthit{$rblastname}}){
                    $fb3name = $ref;
                    $fb3no = $rblasthit{$rblastname}{$ref};
                    last;
                }
	    }  
	    print "$fblastname\t$fb1name\t$fb1no\t$fb2name\t$fb2no\t$rblastname\t$fb3name\t$fb3no\tChimeric\t$clpair{$fblastname}{$rblastname}\tNon-mock\n";
	    $totalchimeric+=$clpair{$fblastname}{$rblastname};
	}
    } else {
	print "$fblastname\tNA\tNA\tNA\tNA\t$rblastname\tNA\tNA\tMissing Blast- Unknown\t$clpair{$fblastname}{$rblastname}\tNon-mock\n";
	$totalbad+=$clpair{$fblastname}{$rblastname};
    }
}
}
print "Non-chimeric\t$totalnonchimera\nIn Mock\t$inmock\nChimeric\t$totalchimeric\nMissint Blast- Unknown\t$totalbad\n";
foreach $mock (keys %mockname){
    print "$mock\t$mockname{$mock}\n";
}
