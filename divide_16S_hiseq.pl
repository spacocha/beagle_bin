#! /usr/bin/perl
#
#

	die "Use this file to divide your entire library into barcodes-specific files
Dividing barcodes will make the downstream processing faster and easier, especially on a cluster
For the last option, say yes or no if your barcodes are in the reverse complement
Usage: <Solexa File> <lib_barcode_file> <output_prefix> <yes/no_rc_bar> <logfile> <statfile> <SEEDFILE_output>\n" unless (@ARGV);
	($file1, $barfile, $output, $rcyes, $logfile, $statfile, $seed) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($barfile);
chomp ($output);
chomp ($rcyes);
chomp ($logfile);
chomp ($statfile);
chomp ($seed);

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
$newyear = $year+1900;
$newmonth=$mon+1;
$lt= "$newmonth-$mday-$newyear $hour:$min:$sec";
open (LOG, ">>$logfile") or die "Can't open $logfile\n";
open (STAT, ">>$statfile") or die "Can't open $statfile\n";
open (SEED, ">$seed") or die "Can't open ${seed}\n";

print LOG "Running divide_16S_hiseq.pl on (m-d-y): $lt
OPTIONS:
Solexa File: $file1
Library_Barcode file: $barfile
Outputname: $output
Barcode in Reverse complement: $rcyes\n\n";

open (IN1, "<$barfile") or die "Can't open $barfile\n";
while ($line=<IN1>){
    chomp ($line);
    next unless ($line);
    ($lib, @pieces) = split ("\t", $line);
    $lib=~s/ //g;#remove spaces
    foreach $rc_seq (@pieces){
	next unless ($rc_seq);
	$rc_seq=~s/ //g;#remove spaces
	if ($rcyes=~/[Yy]/){
	    ($bar_rc) = revcomp();
	    $rc_seq = $bar_rc;
	}
	$barhash{$rc_seq}++;
	open ($rc_seq, ">${output}.${lib}_${rc_seq}") or die "Can't open ${output}.${lib}_${rc_seq}\n";
	print SEED "${output}.${lib}_${rc_seq}\n";
    }
}
close (IN1);

open (IN2, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN2>){
		chomp ($line);
		next unless ($line);
		($header, $sequence, $qual)=split(":", $line);
		$totalreads++;
		#only keep sequences that have the exact bar code right at the beginning of 3rd read
		($barcode) = $header=~/^.+\#.*(.{7})\//;
		$bartotalhash{$barcode}++;
		next unless ($barhash{$barcode});
		$totalkept++;
		print $barcode "${header}:${sequence}:${qual}\n";

	    }
	close (IN2);
foreach $bar (keys %barhash){
    close ($bar);
}

print LOG "The total number of reads were: $totalreads\n";
$percent = 100*$totalkept/$totalreads;
if ($percent >0.75){
    print LOG "The total number of reads kept after barcode filtering: $totalkept ($percent)\n";
    print STAT "The total number of reads kept after barcode filtering: $totalkept ($percent)\n";
} else {
    print LOG "WARNING: TOTAL NUMBER OF READS KEPT IS LOW! $totalkept ($percent)
Bar codes may have been incorrectly read\n";
    print STAT "WARNING: TOTAL NUMBER OF READS KEPT IS LOW! $totalkept ($percent)
Bar codes may have been incorrectly read\n";

}

print STAT "Barcode\tTotal Counts\tPercent of Total Reads\tPercent of Total Kept Reads\n";
foreach $bar (sort {$bartotalhash{$b}<=>$bartotalhash{$a}} keys %bartotalhash){
    $percent = 100*$bartotalhash{$bar}/$totalreads;
    $percentkept = 100*$bartotalhash{$bar}/$totalkept;
    print STAT "$bar\t$bartotalhash{$bar}\t$percent\t$percentkept";
    if ($barhash{$bar}){
	print STAT "\tTrue Barcode\n";
    } else {
	print STAT "\tFalse Barcode\n";
    }
}
close (LOG);
close (STAT);
close (SEED);

sub revcomp{
    my(@pieces);
    (@pieces) = split ("", $rc_seq);
    #make reverse complement
    $j = @pieces;
    $j-=1;
    $seq = ();
    until ($j < 0){
	if ($pieces[$j]){
	    if ($pieces[$j] eq "A"){
		$seq = "$seq"."T";
	    } elsif ($pieces[$j] eq "T"){
		$seq = "$seq"."A";
	    } elsif ($pieces[$j] eq "C"){
		$seq = "$seq"."G";
	    } elsif ($pieces[$j] eq "G"){
		$seq = "$seq"."C";
	    } elsif ($pieces[$j] eq "N"){
		$seq = "$seq"."N";
	    } else {
		die "RC NO Piece: $pieces[$j]\n";
	    }
	} else {
	    die "NO j $j\n";
	}
	$j--;
    }
    return ($seq);
}
