#! /usr/bin/perl -w

die "Usage: results > redirect\n" unless (@ARGV);

($file)=(@ARGV);
chomp ($file);

open (IN, "<$file" ) or die "Can't open $file\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    if ($line=~/Y$/){
	$recid="yes";
    } else {
	$recid="no";
    }
    #these are just the recombs
    (@pieces)= split ("\t", $line);
    next if ($pieces[1]=~/trueseq/);
    ($dist, $len, $ori)=$pieces[1]=~/Dist_(.+)_(.+)_([12][12])\/ab=10/;
    $disthash{$dist}{$recid}++;
    $lenhash{$len}{$recid}++;
    $orihash{$ori}{$recid}++;
}
close (IN);
$yes="yes";
$n = "no";
print "Distance\tyes\tno\n";
foreach $dist (sort {$a <=> $b} keys %disthash){
    $disthash{$dist}{$yes}= 0 unless ($disthash{$dist}{$yes});
    $disthash{$dist}{$n}= 0 unless ($disthash{$dist}{$n});
    print "$dist\t$disthash{$dist}{$yes}\t$disthash{$dist}{$n}\n";
}

print "Length\tyes\tno\n";
foreach $len (sort {$a <=> $b} keys %lenhash){
    $lenhash{$len}{$yes}= 0 unless ($lenhash{$len}{$yes});
    $lenhash{$len}{$n}= 0 unless ($lenhash{$len}{$n});
    print "$len\t$lenhash{$len}{$yes}\t$lenhash{$len}{$n}\n";
}

print "Orientation\tyes\tno\n";
foreach $ori (sort {$a <=> $b} keys %orihash){
    $orihash{$ori}{$yes}= 0 unless ($orihash{$ori}{$yes});
    $orihash{$ori}{$n}= 0 unless ($orihash{$ori}{$n});
    print "$ori\t$orihash{$ori}{$yes}\t$orihash{$ori}{$n}\n";
}
