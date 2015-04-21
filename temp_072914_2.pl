#! /usr/bin/perl -w

die "Usage: bold_ids meta_bold tax dist> redirect\n" unless (@ARGV);
($bold, $metabold, $tax, $dist) = (@ARGV);
chomp ($bold, $tax, $dist, $metabold);

$count=0;
open (IN, "<$bold" ) or die "Can't open $bold\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    die "Missing $line\n" unless ($line);
    $bold_ids{$count}=$line;
    $count++;
}

close (IN);
$count=0;
open (IN, "<$metabold" ) or die "Can't open $metabold\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    die "Missing $line\n" unless ($line);
    $metabold_ids{$count}=$line;
    $count++;
}

close (IN);

$count=0;

open (IN, "<$tax" ) or die "Can't open $tax\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    die "Missing $line\n" unless ($line);
    if ($bold_ids{$count}){
	$taxhash{$bold_ids{$count}}=$line;
    } else {
	die "Missing $count $line $bold_ids{$count}\n";
    }
    $count++;
}
close (IN);

$count=0;
open (IN, "<$dist" ) or die "Can't open $dist\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    if ($bold_ids{$count}){
	if ($taxhash{$bold_ids{$count}}){
	    if ($taxhash{$bold_ids{$count}}=~/Archaea/){
		$i=0;
		$j=@pieces;
		until ($i >=$j){
		    $disthash{$bold_ids{$count}}{$metabold_ids{$i}}=$pieces[$i];
		    $i++;
		}
	    }
	}
    }
    $count++;
}

close (IN);

$totalcount=0;
foreach $arch (sort keys %disthash){
    next unless (%{$disthash{$arch}});
    foreach $others (sort {$disthash{$arch}{$a} <=> $disthash{$arch}{$b}} keys %{$disthash{$arch}}){
	if ($totalcount>20){
	    $totalcount=0;
	    last;
	}
	print "$arch\t$taxhash{$arch}\t$others\t$disthash{$arch}{$others}\n";
	$totalcount++;
    }
}
