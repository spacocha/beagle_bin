#! /usr/bin/perl -w
#
#

	die "Usage: tab_file_w_UC_cluster > Redirect\n" unless (@ARGV);
	($file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file2);

open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, $fseq, $fqual, $rseq, $FreClu, $UC)=split ("\t", $line);
		next unless ($name);
		$hash{$UC}{$FreClu}++;
		$UChash{$name}=$UC;
		$FreCluhash{$name}=$FreClu;
		($bar) = $name =~/^.+\#.*(.{7})$/;
		next unless ($bar);
		$barcount{$FreClu}{$bar}++;
		$totalbar{$bar}++;

       	}
close (IN);

print "Parsing UC clusters...\n";
foreach $UC (keys %hash){
    #within a UC cluster, get all of the FreClu clusters
    $total = 0;
    foreach $FreClu (keys %{$hash{$UC}}){
	$total++;
	$fcname = $FreClu;
    }
    #If there is only one FreClu cluster in the UC group, you don't have to do this correlation
    if ($total == 1){
	print "I'm done with this cluster $UC $fcname\n";
	next;
    } else {
	#what is the distribution of the FreClu cluster across bars?
	#write out to a file.dat to be read by R
	open (OUTDAT, ">/home/spacocha/file.dat") or die "Can't open /home/spacocha/file.dat\n";
        open (OUTSET, ">/home/spacocha/file.set") or die "Can't open /home/spacocha/file.set\n";
	$first = 1;
	foreach $FreClu (sort keys %{$hash{$UC}}){
	    if ($first){
		print OUTDAT "Barcode";
		$first = ();
	    } else {
		print OUTDAT "\t$FreClu";
	    }
	}
	print OUTDAT "\n";
	foreach $bar (sort keys %totalbar){
	    $first = 1;
	    #store the FreClu cluster names for later reference
	    $pvalnum = 1;
	    foreach $FreClu (sort keys %{$hash{$UC}}){
		$pvalnumhash{$pvalnum}=$FreClu;
		$pvalnum++;
	    }
	    #Write the data out in column form
	    foreach $FreClu (sort keys %{$hash{$UC}}){
		$barcount{$FreClu}{$bar}=0 unless ($barcount{$FreClu}{$bar});
		if ($first){
		    print OUTDAT "$bar\t$barcount{$FreClu}{$bar}";
		    $first = ();
		} else {
		    print OUTDAT "\t$barcount{$FreClu}{$bar}";
		}
	    }
	    print OUTDAT "\n";
	}
	close (OUTDAT);
	$pvalnumo = $pvalnum -1;
	print OUTSET "25\t$pvalnumo\n";
	close (OUTSET);
    }
}
