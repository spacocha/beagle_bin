#! /usr/bin/perl -w
#
#

	die "Usage: aligned_file tab_file threshold > Redirect\n" unless (@ARGV);
	($file2, $file3, $thresh) = (@ARGV);

	die "Please follow command line args\n" unless ($thresh);
chomp ($file2);
chomp ($file3);
chomp ($thresh);

$/ = ">";
$total=0;
open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, @seqs)=split ("\n", $line);
		next unless ($name);
		$sequence = join ("", @seqs);
		$hash{$name}=$sequence;
		($long)=$sequence=~/^.(.{172})/;
                ($med)=$sequence=~/^.(.{149})/;
                ($shrt)=$sequence=~/^.(.{125})/;
		if ($long=~/^[AGCT-]+$/){
		    #if there are no gaps (.) in this sequence, record as plus
		    $longno++;
		} 
		if ($med=~/^[AGCT-]+$/){
                    #if there are no gaps (.) in this sequence, record as plus                                                                                                                                 
		    $medno++;
		}
		if ($shrt=~/^[AGCT-]+$/){
                    #if there are no gaps (.) in this sequence, record as plus                                                                                                                                 
		    $shrtno++;
		}
		$total++;

       	}
close (IN);

$longper = 100*$longno/$total;
$medper = 100*$medno/$total;
$shrtper = 100*$shrtno/$total;

if ($longper >= $thresh){
    $keeplen = 172;
} elsif ($medper >= $thresh){
    $keeplen = 149;
} elsif ($shrtper >=$thresh) {
    $keeplen = 125;
} else {
    die "Your threshold value is not met Short: $shrtper\n";
}

$/ = "\n";
$total=0;
open (IN, "<$file3") or die "Can't open $file3\n";
        while ($line=<IN>){
                chomp ($line);
                next unless ($line);
                ($name, $lib, $fseq, $fqual, $rseq, $rqual)=split ("\t", $line);
		if ($hash{$name}){
		    #this sequence aligned
		    ($what, $checkseq) = $hash{$name}=~/^(.)(.{$keeplen})/;
		    if ($checkseq=~/^[ATGC-]+$/){
			#retain this sequence
			$aligned = $checkseq;
			$checkseq =~s/-//g;
			$checklen = split ("", $checkseq);
			if ($what eq "."){
			    ($newfseq) = $fseq=~/^(.{$checklen})/;
			    ($newfqual) = $fqual =~/^(.{$checklen})/;
			} else {
			    ($newfseq) = $fseq=~/^.(.{$checklen})/;
			    ($newfqual) = $fqual=~/^.(.{$checklen})/;
			}
			print "$name\t$lib\t$newfseq\t$newfqual\t$rseq\t$rqual\t$aligned\n";
		    } else {
			#does not get retained because it's too short
		    }
		} else {
		    #does not get retained because it did not align
		}
	    }
close (IN);
