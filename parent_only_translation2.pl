#! /usr/bin/perl -w

die "Use this to convert a bunch of error files across lanes into one big list
A parent in any file will become a parent in all
list is a tab file with final_list\tall_fasta_file\tall_mat_file
fasta is necessary for translation
Usage: tab_of_lists fafile matfile output_prefix\n" unless (@ARGV);
($tab, $fafile, $matfile, $output) = (@ARGV);
chomp ($tab);
chomp ($matfile);
chomp ($fafile);
chomp ($output);

die "Please follow command line instructions\n" unless ($output);

#read in the error list with error file and fasta associated with it
open (IN, "<$tab" ) or die "Can't open $tab\n";
while ($line=<IN>){
    chomp ($line);
    $filehash{$line}++;
}
close (IN);

#start to create the 
$OTUc=1;
open (TRANS, ">${output}.trans") or die "Can't open ${output}.trans\n";
foreach $list (sort keys %filehash){
    #get the parent from the list
    $/="\n";
    open (LIST, "<$list") or die "Can't open $list\n";
    while ($line=<LIST>){
        chomp ($line);
        next unless ($line);
        ($parent, @children)=split ("\t", $line);
	$parenthash{$parent}++;
    }
    close (LIST);
}

#first go through and get all the parent seqeunces and name them
$/=">";
#get sequences for all parents
open (FA, "<$fafile") or die "Can't open $fafile\n";
while ($line=<FA>){
    chomp ($line);
    next unless ($line);
    ($name, @seqs)=split ("\n", $line);
    ($sequence)=join("", @seqs);
    #does this seqeunce exist in the parent hash
    $seqhash{$name}=$sequence if ($parenthash{$name}); 
}
close (FA);

$/="\n";
@headers=();
open (MAT, "<$matfile") or die "Can't open $matfile\n";
while ($line=<MAT>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if (@headers){
	#only get a mat value for parents
	if ($parenthash{$OTU}){
	    $i=0;
	    $j=@pieces;
	    until ($i>=$j){
		$newheader="$headers[$i]";
		$mathash{$OTU}{$newheader}=$pieces[$i];
		$alllibhash{$newheader}++;
		$i++;
	    }
	}
    } else {
	(@headers)=@pieces;
    }
}
close (MAT);

open (OUTMAT, ">${output}.mat") or die "Can't open ${output}.mat\n";
open (OUTFA, ">${output}.fa") or die "Can't open ${output}.fa\n";
#record the header files
print OUTMAT "OTU";
foreach $lib (sort keys %alllibhash){
    print OUTMAT "\t$lib";
}
print OUTMAT "\n";

foreach $parent (sort keys %parenthash){
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
