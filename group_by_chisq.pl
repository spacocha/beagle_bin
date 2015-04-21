#! /usr/bin/perl -w
#
#

	die "Usage: fasta_file remove_file total_files_needed > Redirect\n" unless (@ARGV);
	($file2, $remove, $number) = (@ARGV);

	die "Please follow command line args\n" unless ($number);
chomp ($file2);
chomp ($remove);
chomp ($number);

open (IN, "<$remove") or die "Can't open $remove\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    $rmhash{$line}++;
}
close (IN);

$/ = ">";
$total=0;
open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, @seqs)=split ("\n", $line);
		next unless ($name);
		next if ($rmhash{$name});
		$sequence = join ("", @seqs);
		die "LINE: $line $sequence\n"  unless ($sequence);
		if ($hash{$name}){
		    die "$name already has a value\n";
		} else {
		    $hash{$name}=$sequence;
		    $total++;
		}
       	}
close (IN);

$fastas = $total/$number;
$fastas2 = int ($fastas);

$i =1;
$j=0;
open (OUT, ">${file2}.${i}.fa") or die "Can't open ${file2}.${i}.fa\n";
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

    
