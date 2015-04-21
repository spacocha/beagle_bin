#! /usr/bin/perl -w
#
#

	die "Usage: aligned_file tab_file threshold log.txt stat.txt> Redirect\n" unless (@ARGV);
	($file2, $file3, $thresh, $log, $stat) = (@ARGV);

	die "Please follow command line args\n" unless ($thresh);
chomp ($file2);
chomp ($file3);
chomp ($thresh);
chomp ($log);
chomp ($stat);

$/ = ">";
$total=0;
open (LOG, ">>${log}") or die "Can't open $log\n";
print LOG "Running add_aligned_seq.pl where the fseq and fqual are not shortened.\n";
open (STAT, ">>${stat}") or die "Can't open $stat\n";
open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, @seqs)=split ("\n", $line);
		next unless ($name);
		$sequence = join ("", @seqs);
		$hash{$name}=$sequence;
		($long)=$sequence=~/^.(.{32})/;
		if ($long=~/^[ATGC-]+$/){
		    #if there are no gaps (.) in this sequence, record as plus
		    $longno++;
		    if ($long=~/\./){
			die "$long has dots\n";
		    }
		} 
		$total++;

       	}
close (IN);
$longper = 100*$longno/$total;

if ($longper >= $thresh){
    $keeplen = 32;
} else {
    die "Your threshold value is not met Short: $longper\n";
}

print LOG "Keeplength for F read is:$keeplen\n";

$/ = "\n";
$total=0;
open (IN, "<$file3") or die "Can't open $file3\n";
        while ($line=<IN>){
                chomp ($line);
                next unless ($line);
                ($name, $lib, $fseq, $fqual, $shrtseq)=split ("\t", $line);
		$total++;
		if ($hash{$name}){
		    #this sequence aligned
		    ($what, $aligned) = $hash{$name}=~/^(.)(.{$keeplen})/;
		    if ($aligned=~/^[ATGC-]{$keeplen}$/){
			print "$name\t$lib\t$fseq\t$fqual\t$shrtseq\t$aligned\n";
		    } else {
			print "$name\t$lib\t$fseq\t$fqual\t$shrtseq\tremoved\n";
			print STAT "$name removed: not long enough F aligned\n";
			$removedlen++;
		    }
		} else {
		    print "$name\t$lib\t$fseq\t$fqual\t$shrtseq\tremoved\n";
		    print STAT "$name removed: not in F alignment\n";
		    $removedaln++;
		    #does not get retained because it did not align
		}
	    }
close (IN);

$percentlen = 100*${removedlen}/${total};
$percentaln= 100*${removedaln}/${total};

print LOG "Percent removed because of F alignment:$percentaln ($removedaln removed out of $total total)
Percent removed because of F aligned length: $percentlen ($removedlen removed out of $total total)\n";
close (LOG);
close (STAT);
