#! /usr/bin/perl -w

die "Use this program to make random erros in sequence data
This will use the geometric distribution
error_prob- this is the probability used to determine whether a sequence will have an error (0.85 seems ok)
seq_prob- This is the probability used to determine where the error is from the 3' end (0.5 is ok)
For prob use 0.9 for mostly 0's and 0.5 will give about half 0's
Usage: fasta seqs total_no error_prob seq_prob > redirect" unless (@ARGV);
($tab, $readprob, $seqlen) = (@ARGV);
chomp ($tab);
chomp ($readprob);
chomp($seqlen);

open (IN, "<$tab" ) or die "Can't open $tab\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $seqcount, $sequence) = split ("\t", $line);
    $counthash{$name}=$seqcount;
    $seqhash{$name}=$sequence;
} 
close (IN);

foreach $name (sort keys %counthash){

    system ("rm Rfile.tab") if (-e "Rfile.tab");
    open (FIS, ">${Rfile}.chi") or die "Can't open ${Rfile}.chi\n";
    print FIS "test2 <- rgeom($counthash{$name}, 0.80)                                                                                 
write.table(test2,file=\"Rfile.tab\",quote=FALSE, sep=\"\t\")";
    close (FIS);
    
    system ("R --slave --vanilla --silent < Rfile.chi >> Rfile.chi");
    open (RES, "<${Rfile}.chip") or die "Can't open ${Rfile}.chip\n";
    $first=1;
    while ($Rline=<RES>){
	chomp ($Rline);
	(@pieces)=split ("\t", $Rline);
	if ($first){
	    $first=0;
	} else {
	    ($readcount)=$pieces[0];
	    ($toterr)=$pieces[1];
	}
	$i=0;
	$sequence=$seqhash{$name};
	next unless ($sequence);
	until ($i>=$toterr){
	    #generate random error near end of sequence
	    system ("rm Rfile.tab") if (-e "Rfile.tab");
	    open (FIS, ">${Rfile}.chi") or die "Can't open ${Rfile}.chi\n";
    print FIS "test2 <- rgeom(1, 0.50)
write.table(test2,file=\"seq.tab\",quote=FALSE, sep=\"\t\")";
	    close (FIS);

	    system ("R --slave --vanilla --silent < Rfile.chi >> Rfile.chi");
	    open (RES, "<${Rfile}.chip") or die "Can't open ${Rfile}.chip\n";

	}
			  }
    close (RES);
    print LOG "Recording pvalue for $id $oid $cpvalue\n" if ($verbose); 
    #now get expected
}


###################
####subroutines####
###################


sub makeRexecutables {
    open (FIS, ">${Rfile}.chi") or die "Can't open ${Rfile}.chi\n";
    print FIS "test2 <- rgeom($counthash{$name}, 0.80)
write.table(test2,file=\"Rfile.tab\",quote=FALSE, sep=\"\t\")";
close (FIS);
}

