#! /usr/bin/perl -w
#
	die "Use this to add data to a tree at each node
USAGE: <tree file> <temp tree output> <.trans file from rename_remove_clones6.pl> > redirect\n" unless (@ARGV);

($file, $outputtemp, $isofile)= (@ARGV);
chomp ($file);
chomp ($outputtemp);
chomp ($isofile);

open (IN, "<${file}") or die "Can't open $file\n";
while ($line=<IN>){
	chomp ($line);
	$newline = "$newline"."$line";
}
close (IN);
open (IN, "<${isofile}") or die "Can't open $isofile\n";
while ($line=<IN>){
	chomp ($line);
	next unless ($line);
	($transiso, $isolate) = split ("\t", $line);
	push (@{$inserthash{$transiso}}, $isolate);
}
close (IN);
$count=1;
$lnum=1;
	@pieces = split ("", $newline);
	$total=@pieces;
	while ($total){
		$total=$total-1;
		if ($pieces[$total] eq "\)"){
			$matching = "rp"."${count}"."rp";
			$unmatched{$count}++;
			$printhash{$lnum}=$matching;
			$lnum++;
#			print "$matching\n";
			$count++;
		} elsif ($pieces[$total] eq "\("){
			$last = ();
			foreach $match (sort {$b <=> $a} keys %unmatched){
				if ($last){
					$newunmatched{$match}++;
				} else{
					$matching = "lp"."$match"."lp";
					#print "$matching\n";
					$printhash{$lnum}=$matching;
					$lnum++;
					$last++;
				}
			}
			%unmatched = %newunmatched;
			%newunmatched = ();
		} else {
			#print "$pieces[$total]\n";
			$printhash{$lnum}=$pieces[$total];
			$lnum++;
		}
	}

open (OUT, ">${outputtemp}") or die "Can't open $outputtemp\n";
foreach $lnum (sort {$b <=> $a} keys %printhash){
	print OUT "$printhash{$lnum}";
}
print OUT "\n";
close (OUT);

$newline = ();
open (IN, "<${outputtemp}") or die "Can't open $outputtemp\n";
while ($line=<IN>){
	chomp ($line);
	next unless ($line);
	$newline = "$newline"."$line";
}
close (IN);

#put isolate to the right of every node

$playline= $newline;
$playline =~s/lp[0-9]+lp/>/g;
$playline =~s/rp[0-9]+rp/>/g;
$playline =~s/,/>/g;

(@isos) = split (">", $playline);
foreach $isolate (@isos){
        next unless ($isolate=~/^.+_.+:.+$/);
        ($origiso, $else) = $isolate=~/^(.+?)(:.+)$/;
	$newiso=();
	$newcount=();
	$done=();
	%donehash=();
	$totalarray = (@{$inserthash{$origiso}});
	until ($done){
		$random = int(rand($totalarray));
		$random++;
		next if ($donehash{$random});
		$donehash{$random}++;
		$newrandom= $random-1;
		$random=$newrandom;
		($transiso) =(@{$inserthash{$origiso}}[$random]);
		die "No isolate $transiso $origiso\n" unless ($transiso);
		if ($newiso){
			$old= $newiso;
			die "No old $old\n" unless ($old);
			die "No old $transiso\n" unless ($transiso);
			$newiso = "(${old}:0.00000,${transiso}:0.00000)";
		} else {
			$newiso = $transiso;
		}
		$newcount++;
		$done++ if ($newcount>=$totalarray);
	}

	die "No new iso $newiso $isolate $origiso @{$inserthash{$origiso}}\n" unless ($newiso);
	$new = "${newiso}"."${else}";
        $newline=~s/$isolate/$new/g;

}
	$str1=$newline;
        $str1 =~s/lp[0-9]+lp/\(/g;
        $str1 =~s/rp[0-9]+rp/\)/g;
        print   "${str1}\n";

