#! /usr/bin/perl -w
#
#

	die "Usage: mat rdp output\n" unless (@ARGV);
	($file1, $rdp, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($rdp);
chomp ($output);
$/=">";
open (IN, "<$rdp") or die "Can't open $rdp\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($info, $seq)=split ("\n", $line);
    ($root, $rootval, $doman, $domainval, $phylum, $phylumval)=split ("; ", $seq);
    ($short)=$info=~/^\s*(.+) reverse/;
    $short=~s/ //;
    if ($phylumval>0.5){
	$idhash{$short}=$phylum;
    } else {
	$idhash{$short}="Unknown";
    }
}

foreach $id (sort keys %idhash){
    ($phylum)=$idhash{$id};
    if ($done{$phylum}){
	next;
    } else {
	open ($phylum, ">${output}_${phylum}.txt") or die "Can't open ${output}_${phylum}.txt\n";
	$done{$phylum}++;
    }
}

$/="\n";
$first=1;
open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @pieces)=split ("\t", $line);
    if ($first){
	(@headers)=(@pieces);
	foreach $id (sort keys %done){
	    print $id "ID";
	    foreach $header (@headers){
		print $id "\t$header";
	    }
	    print $id "\n";
	}
	$first=();

    } else {
	if ($idhash{$info}){
	    ($id)=$idhash{$info};
	    $j=@pieces;
	    $i=0;
	    print $id "$info";
	    until ($i>=$j){
		$hash{$info}{$headers[$i]}=$pieces[$i];
		print $id "\t$pieces[$i]";
		$i++;
	    }
	    print $id "\n";
	} else {
	    die "Missing rdp $info\n";
	}
    }
}


foreach $id (sort keys %idhash){
    close ($id);
}
