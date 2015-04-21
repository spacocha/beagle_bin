#! /usr/bin/perl -w

die "Use this to convert a bunch of error files across lanes into one big list
A parent in any file will become a parent in all
list is a tab file with final_list\tall_fasta_file\tall_mat_file
fasta is necessary for translation
Usage: tab_file output_prefix\n" unless (@ARGV);
($tab, $output) = (@ARGV);
chomp ($tab);
chomp ($output);

die "Please follow command line instructions\n" unless ($output);

#read in the error list with error file and fasta associated with it
open (IN, "<$tab" ) or die "Can't open $tab\n";
while ($line=<IN>){
    chomp ($line);
    ($listfile, $fasta, $matfile)=split ("\t", $line);
    $seqfilehash{$listfile}=$fasta;
    $matfilehash{$listfile}=$matfile;
    $filehash{$listfile}++;
}
close (IN);

#start to create the 
$OTUc=1;
open (TRANS, ">${output}.trans") or die "Can't open ${seqfilehash{$list}}\n";
foreach $list (sort keys %filehash){
    #get the parent from the list
    $/="\n";
    open (LIST, "<$list") or die "Can't open $list\n";
    while ($line=<LIST>){
        chomp ($line);
        next unless ($line);
        ($parent, @children)=split ("\t", $line);
	$parenthash{$list}{$parent}++;
    }
    close (LIST);
}

#first go through and get all the parent seqeunces and name them
foreach $list (sort keys %filehash){
    $/=">";
    #get sequences for all parents
    open (FA, "<${seqfilehash{$list}}") or die "Can't open ${seqfilehash{$list}}\n";
    while ($line=<FA>){
	chomp ($line);
	next unless ($line);
	($name, @seqs)=split ("\n", $line);
	($sequence)=join("", @seqs);
	#does this seqeunce exist in the parent hash
	if ($parenthash{$list}{$name}){
	    if ($mergehash{$sequence}){
		#it has a new name
		#store the new name with the errorfile
		$transhash{$list}{$name}=$mergehash{$sequence};
		$seqhash{$mergehash{$sequence}}=$sequence;
		print TRANS "$list\t$name\t$mergehash{$sequence}\n";
	    } else {
		#define the new translated name
		(@piecesc) = split ("", $OTUc);
		$these = @piecesc;
		#change this number if you run out of counts
		$zerono = 7 - $these;
		$zerolet = "0";
		$zeros = $zerolet x $zerono;
		$OTUn="MG${zeros}${OTUc}T";
		$OTUc++;
		$mergehash{$sequence}=$OTUn;
		print TRANS "$OTUn\t$sequence\n";
		$transhash{$list}{$name}=$mergehash{$sequence};
		$seqhash{$mergehash{$sequence}}=$sequence;
		print TRANS "$list\t$name\t$mergehash{$sequence}\n";
		
	    }
	} 
    }
    close (FA);
}

#find parent sequences in other files that were not called parents
foreach $list (sort keys %filehash){
    $/=">";
    open (FA, "<${seqfilehash{$list}}") or die "Can't open ${seqfilehash{$list}}\n";
    while ($line=<FA>){
        chomp ($line);
        next unless ($line);
        ($name, @seqs)=split ("\n", $line);
	($sequence)=join("", @seqs);
	if ($mergehash{$sequence}){
	    #it's a parent sequence, so store name
	    $transhash{$list}{$name}=$mergehash{$sequence} unless ($transhash{$list}{$name});
	}
    }
    close (FA);
    $/="\n";
    @headers=();
    open (MAT, "<${matfilehash{$list}}") or die "Can't open ${matfilehash{$list}}\n";
    while ($line=<MAT>){
        chomp ($line);
        next unless ($line);
	($OTU, @pieces)=split ("\t", $line);
	if (@headers){
	    #only get a mat value for parents
	    if ($transhash{$list}{$OTU}){
		$transOTU=$transhash{$list}{$OTU};
		$i=0;
		$j=@pieces;
		until ($i>=$j){
		    $newheader="$list"."$headers[$i]";
		    $mathash{$transOTU}{$newheader}=$pieces[$i];
		    $alllibhash{$newheader}++;
		    $i++;
		}
	    }
	} else {
	    (@headers)=@pieces;
	}
    }
    close (MAT);
}

$/="\n";
#In this step, I have to define the new merged parent name in the parent hash
foreach $listfile (sort keys %filehash){
    open (IN, "<${listfile}") or die "Can't open ${listfile}\n";
    while ($line =<IN>){
	chomp ($line);
	next unless ($line);
	($parent, @children)=split ("\t", $line);
	if ($transhash{$listfile}{$parent}){
	    #each parent has a new name
	    $mergedparenthash{$transhash{$listfile}{$parent}}++;
	} else {
	    die "In listfile: Missing translation $parent $listfile\n";
	}
    }
    close (IN);
}

open (OUTMAT, ">${output}.mat") or die "Can't open ${output}.mat\n";
open (OUTFA, ">${output}.fa") or die "Can't open ${output}.fa\n";
#record the header files
print OUTMAT "OTU";
foreach $lib (sort keys %alllibhash){
    print OUTMAT "\t$lib";
}
print OUTMAT "\n";

foreach $parent (sort keys %mergedparenthash){
    print OUTMAT "$parent";
    if ($seqhash{$parent}){
	print OUTFA ">$parent\n$seqhash{$parent}\n";
    } else {
	die "Missing seq $parent $seqhash{$parent}\n";
    }
    foreach $lib (sort keys %alllibhash){
	if ($mathash{$parent}{$lib}){
	    print OUTMAT "\t$mathash{$parent}{$lib}";
	} else {
	    print OUTMAT "\t0";
	}
    }
    print OUTMAT "\n";

}
close (OUTMAT);
close (OUTFA);
close (TRANS);
