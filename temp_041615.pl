#! /usr/bin/perl -w

die "Usage: fasta > redirectoutput\n" unless (@ARGV);
($fasta) = (@ARGV);
chomp ($fasta);

open (IN1, "<$fasta" ) or die "Can't open $fasta\n";
$/=">";
while ($line1 =<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($header1, @pieces)=split ("\n", $line1);
    ($sequence)=join("", @pieces);
    (@bases) = split("", $sequence);
    $length=@bases;
    $previousbase="NA";
    $homolength=1;
    $calcnum=0;
    $calcdom=0;
    $i=0;
    $j=$length;
    until ($i >=$j){
	if ($bases[$i] eq $previousbase){
	    $homolength++;
	} else {
	    $previousbase=$bases[$i];
	    $calcnum+=$homolength;
	    $calcdom++;
	    $homolength=1;
	}
	$i++;
    }
    $ave=$calcnum/$calcdom;
    #what if I have multiple different averages of the same length?
    print "$length\t$ave\n";
}

close (IN1);



