#! /usr/bin/perl -w
#
#

	die "Use this to split a fasta file for parallel processing
Output will be in the form of filebase.no.fa where filebase is the part before \.*f*a*s*t*a*
Usage: fasta_file total_files_needed > Redirect\n" unless (@ARGV);
	($file2, $number) = (@ARGV);

	die "Please follow command line args\n" unless ($number);
chomp ($file2);
chomp ($number);

$/ = ">";
$total=0;
open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, @seqs)=split ("\n", $line);
		next unless ($name);
		$sequence = join ("", @seqs);
		print "MISSING SEQUENCE: $line $sequence\n"  unless ($sequence);
		if ($hash{$name}){
		    #don't repeat
		} else {
		    $hash{$name}=$sequence;
		    $total++;
		}
       	}
close (IN);

$fastas = $total/$number;
$fastas2 = int ($fastas);
$fastas2+=1;

$i =1;
$j=0;
($base)=$file2=~/^(.+)\.*f*a*s*t*a*$/;
open (OUT, ">${base}.${i}.fa") or die "Can't open ${base}.${i}.fa\n";
$i++;
foreach $name (sort keys %hash){
    if ($j >=$fastas2){
	$j=0;
	close (OUT);
	open (OUT, ">${file2}.${i}.fa") or die "Can't open ${file2}.${i}.fa\n";
	$i++;
	print OUT ">$name\n$hash{$name}\n";
	$j++;
    } else {
	print OUT ">$name\n$hash{$name}\n";
	$j++;
    }
}

    
