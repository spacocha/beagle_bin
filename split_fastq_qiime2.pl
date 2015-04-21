#! /usr/bin/perl -w
#
#

	die "Use this to split a fastq file for parallel processing
Usage: fastq_file number_per_file output\n" unless (@ARGV);
	($file2, $number, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file2);
chomp ($number);
chomp ($output);

$/ = "@";
$total=0;
$count=1;
open (IN, "<$file2") or die "Can't open $file2\n";
open (OUT, ">${output}.${count}.fastq") or die "Can't open ${output}.${count}.fastq\n";
open (TAB, ">${output}.tab") or die "Can't open ${output}.tab\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, $seq, $name2, $qual)=split ("\n", $line);
		next unless ($name);
		print "MISSING SEQUENCE: $line $seq\n"  unless ($seq);
		if ($total>=$number){
		    close (OUT);
		    $count++;
		    $total=0;
		    open (OUT, ">${output}.${count}.fastq") or die "Can't open ${output}.${count}.fastq\n";
		    print OUT "\@$name\n$seq\n$name2\n$qual\n";
		    print TAB "$name\t${output}.${count}.fastq\n";
		    $total++;
		} else {
		    print OUT "\@$name\n$seq\n$name2\n$qual\n";
		    print TAB "$name\t${output}.${count}.fastq\n";
		    $total++;
		}
       	}
close (IN);
close (OUT);

