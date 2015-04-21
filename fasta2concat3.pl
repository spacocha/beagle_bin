#! /usr/bin/perl -w
#
#
	die "Use this to concat fasta files (must begin with gene_.)
Usage: <.fa files that you want concatenated> > Redirect\n" unless (@ARGV);

$/ = ">";
chomp (@ARGV);
foreach $file (@ARGV){
	($gene) = $file =~/^(.+?)_/;
	open (IN, "<$file") or die "Can't open $file\n";
	while ($line = <IN>){
		chomp ($line);
		next unless ($line);
		(@pieces) = split ("\n", $line);
		($isolate) = shift (@pieces);
		($sequence) = join ("", @pieces);
		$sequence =~ tr/"\n"//d;
		$seqhash{$isolate}{$gene}=$sequence;
	}
	close (IN);
}

foreach $isolate (keys %seqhash){
	print ">${isolate}";
	$newseq = ();
	foreach $gene (sort keys %{$seqhash{$isolate}}){
		#print "_${gene}";
		if ($newseq){
			$newseq = "$newseq"."$seqhash{$isolate}{$gene}";
		} else {
			$newseq = $seqhash{$isolate}{$gene};
		}
	}
	print "\n$newseq\n\n";
}
