#! /usr/bin/perl -w
#
#

	die "Usage: Tab_File (DNA only) Info_column Seq_Column_f Seq_Column_r Output_name\n" unless (@ARGV);
	($file, $info, $seqf, $seqr, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($file && $info && $seqr);
	chomp ($info);
	chomp ($seqf);
chomp ($seqr);
	$info-=1;
	$seqf-=1;
$seqr-=1;
chomp ($output);
$count=1;
	open (IN, "<$file") or die "Can't open $file\n";
	while ($line=<IN>){
		chomp ($line);
		(@a) = split ("\t", $line);
		($sequencef) = $a[$seqf];
		($sequencer) = $a[$seqr];
		${rc_seq} = $sequencer;
		($rcseqr) = revcomp ();
		next unless ($sequencef =~/[CATGXN-]/i);
                next unless ($rcseqr =~/[CATGXN-]/i);
		(@ford) = split ("", $sequencef);
		(@rev) = split ("", $rcseqr);
		$f = @ford;
		$r = @rev;
		$length = 192-$f -$r;
		$letter = "N";
		$Ns = $letter x $length;
		$silva = "$sequencef"."$Ns"."$rcseqr";
		$store{$count}=">$a[$info]\n$silva";
		
		$count++;
	}
	close (IN);
	
$temp = $count/24;
$printcount=1;
$outcount=1;
open (OUT, ">${printcount}_${output}") or die "Can't open ${printcount}_${output}\n";
foreach $count (keys %store){
    if ($outcount > $temp){
	close (OUT);
	$printcount++;
	open (OUT, ">${printcount}_${output}") or die "Can't open ${printcount}_${output}\n";
	print OUT "$store{$count}\n";
	$outcount=1;
    } else {
	print OUT "$store{$count}\n";
	$outcount++;
    }
}


sub revcomp{
    (@pieces) = split ("", $rc_seq);
    #make reverse complement
    $j = @pieces;
    $j-=1;
    $seq = ();
    until ($j < 0){
	if ($pieces[$j]){
	    if ($pieces[$j] eq "A"){
		$newlet = "T";
	    } elsif ($pieces[$j] eq "T"){
		$newlet = "A";
	    } elsif ($pieces[$j] eq "C"){
		$newlet = "G";
	    } elsif ($pieces[$j] eq "G"){
		$newlet = "C";
	    } elsif ($pieces[$j] eq "N"){
		$newlet = "N";
	    } else {
		die "$pieces[$j]\n";
	    }
	    if ($seq){
		$seq = "$seq"."$newlet";
	    } else {
		$seq = "$newlet";
	    }
		
	} else {
	    die "NO j $j\n";
	}
	$j--;
    }
    return ($seq);
}
