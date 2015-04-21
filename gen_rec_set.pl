#! /usr/bin/perl -w

die "Usage: dst file fasta > redirect\n" unless (@ARGV);

($dst, $fasta)=(@ARGV);
chomp ($dst, $fasta);

$k=1;
open (IN, "<$dst") or die "Can't open $dst\n";
while ($line=<IN>){
    chomp ($line);
    (@pieces) = split (" ", $line);
    if ($pieces[0] =~/[A-z]/){
#start a new entry
	($isolate) = shift (@pieces);
	$j=1;
	$translatehash2{$k}=$isolate;
	$k++;
    }
    
    foreach $distance (@pieces){
	$disthash{$isolate}{$j}=$distance;
	$j++;
    }
    
}
close (IN);

$/=">";
open (IN, "<$fasta" ) or die "Can't open $fasta\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @seqs)= split ("\n", $line);
    ($sequence)=join ("", @seqs);
    $seqhash{$name}=$sequence;
}
close (IN);

$newisocount=0;
#now generate a set of chimeric seqeunces
#first pick distances that are equally spaced every 0.025 or so
$err=0.005;
$increment=0.025;
foreach $iso (sort keys %disthash){
    foreach $val (sort keys %{$disthash{$iso}}){
	$j=10;
	$i=1;
	until ($i >$j){
	    $fval=${i}*${increment} + $err;
	    $sval=${i}*${increment} - $err;
	    $checkdist=${i}*${increment};
	    if ($done{$checkdist}){
		if ($done{$checkdist} < 10){
		    if ($disthash{$iso}{$val} <= $fval && $disthash{$iso}{$val} > $sval){
			die "Iso $iso val $val iso $seqhash{$iso} val $seqhash{$translatehash2{$val}}\n" unless ($seqhash{$iso} && $seqhash{$translatehash2{$val}});
			if ($seqhash{$iso} && $seqhash{$translatehash2{$val}}){
			    #make them into rec seqs
			    ($result)=genrecs($seqhash{$iso}, $seqhash{$translatehash2{$val}}, $checkdist);
			    $done{$checkdist}++;
			}
		    }
		}
	    } else {
		if ($disthash{$iso}{$val} <= $fval && $disthash{$iso}{$val} > $sval){
		    die "Iso $iso val $val iso $seqhash{$iso} val $seqhash{$translatehash2{$val}}\n" unless ($seqhash{$iso} && $seqhash{$translatehash2{$val}});
		    if ($seqhash{$iso} && $seqhash{$translatehash2{$val}}){
			($result)=genrecs($seqhash{$iso}, $seqhash{$translatehash2{$val}}, $checkdist);
			$done{$checkdist}++;
		    }
		}
	    }
	    $i++;
	}
    }
}

sub genrecs{
    ($firstseq, $secseq, $dist)=@_;
    $newisocount++;
    $id1=$newisocount;
    $newisocount++;
    $id2=$newisocount;
    print ">Dist_${dist}_trueseq_$id1/ab=100\n$firstseq\n>Dist_${dist}_trueseq_$id2/ab=100\n$secseq\n";
    
    $length = 4;
    $i=1;
    (@bp1)=split ("", $firstseq);
    (@bp2)=split ("", $secseq);
    $j = @bp1;
    $k = @bp2;
    die "$j $k\n" unless ($j == $k);
    until ($i > 19){
	$forlen=$i*$length;
	($front1, $back1)=$firstseq=~/^(.{$forlen})(.*)$/;
	($front2, $back2)=$secseq=~/^(.{$forlen})(.*)$/;
	($newseq12)="$front1"."$back2";
	($newseq21)="$front2"."$back1";
	print ">Dist_${dist}_${forlen}_12/ab=10\n$newseq12\n";
	print ">Dist_${dist}_${forlen}_21/ab=10\n$newseq21\n";
	$i++;
    }
    return ($result);
}
