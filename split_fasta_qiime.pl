#! /usr/bin/perl -w
#
#

	die "Use this to split a fasta file for parallel processing
Usage: fasta_file number_per_file output\n" unless (@ARGV);
	($file2, $number, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file2);
chomp ($number);
chomp ($output);

$/ = ">";
$total=0;
$count=1;
open (IN, "<$file2") or die "Can't open $file2\n";
open (OUT, ">${output}.${count}.fa") or die "Can't open ${output}.${count}.fa\n";
open (TAB, ">${output}.tab") or die "Can't open ${output}.tab\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, @seqs)=split ("\n", $line);
		next unless ($name);
		($library, $read, @extra)=split (" ", $name);
		$sequence = join ("", @seqs);
		print "MISSING SEQUENCE: $line $sequence\n"  unless ($sequence);
		if ($total>$number){
		    close (OUT);
		    $count++;
		    $total=0;
		    open (OUT, ">${output}.${count}.fa") or die "Can't open ${output}.${count}.fa\n";
		    print OUT ">$read\n$sequence\n";
		    print TAB "$read\t${output}.${count}.fa\n";
		    $total++;
		} else {
		    print OUT ">$read\n$sequence\n";
		    print TAB "$read\t${output}.${count}.fa\n";
		    $total++;
		}
       	}
close (IN);
close (OUT);

