#! /usr/bin/perl -w
#
#

	die "Tab file with seq name\tLib\tfSeq\tfQual\tRseq\tRqual\tTAlign\tFreClu cluster\tUC cluster
Will output a matrix for every UC cluster that can be used with man_chisq.pl
Also output a fasta file for every UC cluster that has more than two members
Include universal outgroup files
Usage: tab_file_w_UC_cluster aligned_outgroup_file output_name\n" unless (@ARGV);
	($file2, $outgroup, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file2);
chomp ($outgroup);
chomp ($output);

open (IN, "<$outgroup") or die "Can't open $outgroup\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($ogname, $ogseq)= split ("\t", $line);
    last if ($ogname && $ogseq);
}
close (IN);

open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, $lib, $fseq, $fqual, $rseq, $rqual, $falign, $ID, $FreClu, $UC)=split ("\t", $line);
		next unless ($name && $UC && $lib);
		$seqhash{$FreClu}=$falign;
		$hash{$UC}{$FreClu}++;
		$barcount{$FreClu}{$lib}++;
		$totalbar{$lib}++;

       	}
close (IN);

foreach $UC (keys %hash){
    #within a UC cluster, get all of the FreClu clusters
    $total = 0;
    foreach $FreClu (keys %{$hash{$UC}}){
	$total++;
	$fcname = $FreClu;
    }
    #If there is only one FreClu cluster in the UC group, you don't have to do this correlation
    if ($total == 1){
	#create a file that will be used as part of all of the sequences after chi sq grouping
	open (OUT, ">${output}.${UC}.group") or die "Can't open ${output}.${UC}.group\n";
	print OUT "$fcname,1\n";
	close (OUT);
	next;
    } else {
	#what is the distribution of the FreClu cluster across bars?
	#write to output to be used in man_chisq.pl
	open (OUT, ">${output}.${UC}.chisq.dat") or die "Can't open ${output}.${UC}.chisq.dat\n";
	foreach $FreClu (sort keys %{$hash{$UC}}){
	    print OUT "\t$FreClu";
	}
	print OUT "\n";
	foreach $bar (sort keys %totalbar){
	    print OUT "$bar";
	    #store the FreClu cluster names for later reference
	    #Write the data out in column form
	    foreach $FreClu (sort keys %{$hash{$UC}}){
		$barcount{$FreClu}{$bar}=0 unless ($barcount{$FreClu}{$bar});
		print OUT "\t$barcount{$FreClu}{$bar}";
	    }
	    print OUT "\n";
	}
	close (OUT);
	if ($total > 2){
	    open (OUT, ">${output}.${UC}.fa") or die "Can't open ${output}.${UC}.fa\n";
	    print OUT ">$ogname\n$ogseq\n";
	    foreach $FreClu (sort keys %{$hash{$UC}}){
		print OUT ">$FreClu\n$seqhash{$FreClu}\n";
	    }
	    close (OUT);
	}
    }
}
