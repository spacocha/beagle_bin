#! /usr/bin/perl -w
#
#

	die "Use this to split a fastq file for parallel processing
Usage: fastq_file number_files_needed output\n" unless (@ARGV);
	($file2, $number, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file2);
chomp ($number);
chomp ($output);

$total=0;
$count=1;
open (IN, "<$file2") or die "Can't open $file2\n";
while ($head=<IN>){
    chomp ($head);
    next unless ($head);
    ($seq=<IN>);
    ($head2=<IN>);
    ($qual=<IN>);
    print "MISSING SEQUENCE: $head $seq\n"  unless ($seq);
    $total++;
}
close (IN);

$fastqs = $total/$number;
$fastqs2 = int ($fastqs);
$fastqs2+=1;

$total=0;
$count=1;
open (IN, "<$file2") or die "Can't open $file2\n";
open (OUT, ">${output}.${count}.fastq") or die "Can't open ${output}.${count}.fastq\n";
	while ($head=<IN>){
	    chomp ($head);
	    next unless ($head);
	    ($seq=<IN>);
	    chomp ($seq);
	    ($head2=<IN>);
	    chomp ($head2);
	    ($qual=<IN>);
	    chomp ($qual);
	    print "MISSING SEQUENCE: $head $seq\n"  unless ($seq);
	    if ($total>=$fastqs2){
		close (OUT);
		$count++;
		$total=0;
		open (OUT, ">${output}.${count}.fastq") or die "Can't open ${output}.${count}.fastq\n";
		print OUT "$head\n$seq\n$head2\n$qual\n";
		$total++;
	    } else {
		print OUT "$head\n$seq\n$head2\n$qual\n";
		$total++;
	    }
}
close (IN);
close (OUT);

