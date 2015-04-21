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

$/ = "@";
$total=0;
$count=1;
open (IN, "<$file2") or die "Can't open $file2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $seq, $name2, $qual)=split ("\n", $line);
    next unless ($name);
    print "MISSING SEQUENCE: $line $seq\n"  unless ($seq);
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
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, $seq, $name2, $qual)=split ("\n", $line);
		next unless ($name);
		print "MISSING SEQUENCE: $line $seq\n"  unless ($seq);
		if ($total>$fastqs2){
		    close (OUT);
		    $count++;
		    $total=0;
		    open (OUT, ">${output}.${count}.fastq") or die "Can't open ${output}.${count}.fastq\n";
		    print OUT "\@$name\n$seq\n+$name2\n$qual";
		    $total++;
		} else {
		    print OUT "\@$name\n$seq\n+$name2\n$qual";
		    $total++;
		}
       	}
close (IN);
close (OUT);

