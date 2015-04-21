#! /usr/bin/perl -w
#
#

	die "Usage: blast_report_tab UC_count > Redirect\n" unless (@ARGV);
	($file1, $file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file1);
chomp ($file2);

open (IN, "<$file2") or die "Can't open $file2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($seed, $count)=split ("\t", $line);
    $counthash{$seed}=$count;
}
close (IN);

open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($fastaname, $ref, $id, $per, $gap, $len, $Q)=split ("\t", $line);
    ($newname, $num) = $fastaname =~/^ *[0-9]+\|\*\|(.+)_([12])$/;
    ($hit, $total, $percent) = $id =~/^([0-9]+)\/([0-9]+) \(([0-9]+)\%\)/;
    die unless ($hit);
    $fblasthit{$newname}{$num}{$ref}=$hit;
    $fblasttotal{$newname}{$num}{$ref}=$total;
    $fblastpercent{$newname}{$num}{$ref}=$percent;

}
close (IN);

$one = 1;
$two = 2;
foreach $name (sort {$counthash{$b} <=> $counthash{$a}} keys %counthash){
    unless ($fblasthit{$name}){
	print "$name\tNA\tNA\tNA\tNA\tNA-Poor Quality\t$counthash{$name}\n";
	next;
    }
    $best1=();
    $best2=();
    $bestref1=();
    $bestref2=();
    $found=();
    %keephash1=();
    %keephash2= ();
    $done = ();
    if ($fblasthit{$name}{$one} && $fblasthit{$name}{$two}){
	foreach $ref (sort {$fblasthit{$name}{$one}{$b} <=> $fblasthit{$name}{$one}{$a}} keys %{$fblasthit{$name}{$one}}){
	    $best1 = $fblasthit{$name}{$one}{$ref} unless ($best1);
	    die "No best $name\n" unless ($best1);
	    $bestref1 = $ref unless ($bestref1);
	    $best1m1 = $best1 -1;#allow one mismatch
	    if ($fblasthit{$name}{$one}{$ref} >= $best1m1){
		$keephash1{$ref}++;
	    }
	}
        foreach $ref (sort {$fblasthit{$name}{$two}{$b} <=> $fblasthit{$name}{$two}{$a}} keys %{$fblasthit{$name}{$two}}){
            $best2 = $fblasthit{$name}{$two}{$ref} unless ($best2);
	    $bestref2 = $ref unless ($bestref2);
	    die "No best2 $name\n" unless ($best2);
	    $best2m1 = $best2 - 1;#allow one mismatch
            if ($fblasthit{$name}{$two}{$ref} >= $best2m1){
		$keephash2{$ref}=$best2;
	    }   
        }
	$done = ();
	foreach $ref (keys %keephash1){
	    if ($keephash2{$ref}){
		if ($fblasthit{$name}{$two}{$ref}){
		    print "$name\t$ref\t$fblasthit{$name}{$one}{$ref}\t$ref\t$fblasthit{$name}{$two}{$ref}\tNon-chimeric\t$counthash{$name}\n" unless ($done);
		    $seedhash{$ref}++ unless ($done);
		    $done++;
		} else {
		    die "No fbasthit $ref $name $keephash2{$ref}\n";
		}
	    }
	}
	unless ($done){
	    $newbestref1 = ();
	    $newbestref2 = ();
	    foreach $seedref (keys %seedhash){
		if ($keephash1{$seedref}){
		    $newbestref1=$seedref;
		}
		if ($keephash2{$seedref}){
		    $newbestref2=$seedref;
		}
	    }
	    $newbestref1 = $bestref1 unless ($newbestref1);
	    $newbestref2 = $bestref2 unless ($newbestref2);
	    print "$name\t$newbestref1\t$fblasthit{$name}{$one}{$newbestref1}\t$newbestref2\t$fblasthit{$name}{$two}{$newbestref2}\tChimeric\t$counthash{$name}\n";
	}
    } elsif ($fblasthit{$name}{$one}){
        foreach $ref (sort {$fblasthit{$name}{$one}{$b} <=> $fblasthit{$name}{$one}{$a}} keys %{$fblasthit{$name}{$one}}){
            $best1 = $fblasthit{$name}{$one}{$ref} unless ($best1);
            $bestref1 =$ref unless ($bestref1);
	}

	print "$name\t$bestref1\t$fblasthit{$name}{$one}{$bestref1}\tNA\tNA\tNA-Poor Quality\t$counthash{$name}\n";
    } elsif ($fblasthit{$name}{$two}){
        foreach $ref (sort {$fblasthit{$name}{$two}{$b} <=> $fblasthit{$name}{$two}{$a}} keys %{$fblasthit{$name}{$two}}){
            $best2 = $fblasthit{$name}{$two}{$ref} unless ($best2);
            $bestref2 =$ref unless ($bestref2);
        }

        print "$name\tNA\tNA\t$bestref2\t$fblasthit{$name}{$two}{$bestref2}\tNA-Poor Quality\t$counthash{$name}\n";
    } else {
	print "$name\tNA\tNA\tNA\tNA\tNA-Poor Quality\t$counthash{$name}\n";
    }
}
