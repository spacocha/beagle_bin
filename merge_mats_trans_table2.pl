#! /usr/bin/perl -w

die "This is to merge QIIME formated matrix files picked from a reference. 
They must have lineage information in the last field
Library names and lineages can not have \"QIIME\" in them
matfile_list: a file where each line is the name of a matfile to process
merge_table: a file where the first field is the matfile name and the second field is the unique_fasta
lin: y if there is a linage field (e.g. RDP classification) in last (with no map) or second to last field (with map)
map: y if there is a map field (map2mock) in last field
output_prefix: the beginning of a name, will create .trans and .mat with it
size: the sequence length of the shortest seqeunce. Others will be truncated to this size

This will make all seqeunces the same size:
Usage: matfiles_list merge_table lin map size output_prefix\n" unless (@ARGV);
($matfile, $mergetable, $linanswer, $mapanswer, $size, $output)=(@ARGV);
chomp ($mergetable);
chomp ($matfile);
chomp ($linanswer);
chomp ($mapanswer);
chomp ($output);
chomp ($size);
$forlinhash="Lineage";
$/="\n";
open (MERGE, "<$mergetable" ) or die "Can't open $mergetable\n";
while ($line0 =<MERGE>){
    chomp ($line0);
    next unless ($line0);
    ($matname, $fasta)=split ("\t", $line0);
    $mat2fastahash{$matname}=$fasta;
    $/=">";
    open (IN, "<$fasta" ) or die "Can't open $fasta\n";
    while ($line =<IN>){
        chomp ($line);
	next unless ($line);
	($uniquename, @seqs)=split ("\n", $line);
	($sequence)=join ("", @seqs);
	(@seqbp)=split ("", $sequence);
	$len=@seqbp;
	die "$fasta seqs are two short $len $size\n" unless ($len >=$size);
	($shrtseq)=$sequence=~/^(.{$size})/;
	$seqtranshash{$fasta}{$uniquename}=$shrtseq;
	$transfahash{$fasta}{$shrtseq}{$uniquename}++;
    }
    close (IN);
    $/="\n";
}

open (MAT, "<$matfile" ) or die "Can't open $matfile\n";
while ($mat =<MAT>){
    chomp ($mat);
    next unless ($mat);
    @headers=();
    open (IN, "<$mat" ) or die "Can't open $mat\n";
    while ($line =<IN>){
	chomp ($line);
	next unless ($line);
	next if ($line=~/QIIME/);
	($OTU, @pieces)=split ("\t", $line);
	if (@headers){
	    $i=0;
	    ($map)=pop(@pieces) if ($mapanswer=~/[Yy]/);
	    ($lineage)=pop(@pieces) if ($linanswer=~/[Yy]/);
	    if ($mat2fastahash{$mat}){
		($fasta)=$mat2fastahash{$mat};
	    } else {
		die "Missing a fasta for $mat\n";
	    }
	    if ($seqtranshash{$fasta}{$OTU}){
		($seq)=$seqtranshash{$fasta}{$OTU};
	    } else {
		die "Missing a sequence for $OTU $mat $mat2fastahash{$mat}\n";
	    }
	    $maphash{$seq}=$map if ($mapanswer =~/[Yy]/);
	    if ($linhash{$seq}{$forlinhash}){
		if ($linhash{$seq}{$forlinhash} ne $lineage){
		    die "Different lineage information for $OTU $lineage $linhash{$OTU}{$forlinhash}\n";
		}
	    } else {
		$linhash{$seq}{$forlinhash}=$lineage;
	    }

	    $j=@pieces;
	    until ($i >=$j){
		$value=$pieces[$i];
		$header=$headers[$i];
		$hash{$seq}{$header}+=$value;
		$allheaders{$header}++;
		$i++;
	    }
	} else {
	    (@headers)=@pieces;
	    ($mapname)=pop(@headers) if ($mapanswer=~/[Yy]/);
	    ($linname)=pop(@headers) if ($linanswer=~/[Yy]/);
	}
    }
    close (IN);
}
close (MAT);

open (MATOUT, ">${output}.mat") or die "Can't open ${output}.mat\n";
open (TRANS, ">${output}.trans") or die "Can't open ${output}.trans\n";
print TRANS "SuperOTU";
foreach $transfa (sort keys %transfahash){
    print TRANS "\t$transfa";
}
print TRANS "\n";

foreach $seq (sort keys %hash){
    print MATOUT "SuperOTU";
    foreach $header (sort keys %allheaders){
	print MATOUT "\t$header";
    }
    #use the last name for the lineage
    print MATOUT "\tLin" if ($linanswer=~/[Yy]/);
    print MATOUT "\tMap" if ($mapanswer=~/[Yy]/);
    print MATOUT "\n";
    last;
}

$OTUc=1;
foreach $seq (sort keys %hash){
    #make a superOTU name
    (@piecesc) = split ("", $OTUc);
    $these = @piecesc;
    $zerono = 7 - $these;
    $zerolet = "0";
    $zeros = $zerolet x $zerono;
    $OTUn="ID${zeros}${OTUc}S";
    $OTUc++;
    #now record the names of the other OTUs in the other fasta files with the same seq (some might not exist)
    print TRANS "$OTUn";
    $totalin=0;
    foreach $transfa (sort keys %transfahash){
	print TRANS "\t";
	if ($transfahash{$transfa}{$seq}){
	    foreach $unique (sort keys %{$transfahash{$transfa}{$seq}}){
		print TRANS "$unique,";
	    }
	    $totalin++;
	} else {
	    print TRANS "NA";
	}
    }
    print TRANS "\t$totalin\n";

    print MATOUT "$OTUn";
    foreach $header (sort keys %allheaders){
	if ($hash{$seq}{$header}){
	    print MATOUT "\t$hash{$seq}{$header}";
	} else {
	    print MATOUT "\t0";
	}
    }
    print MATOUT "\t$linhash{$seq}{$forlinhash}" if ($linanswer=~/[Yy]/);
    print MATOUT "\t$maphash{$seq}" if ($mapanswer=~/[Yy]/);
    print MATOUT "\n";
}

