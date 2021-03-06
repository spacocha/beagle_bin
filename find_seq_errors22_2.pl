#! /usr/bin/perl -w
#   Edited on 03/05/12 
#

	die "Usage: perl find_seq_error22_2.pl {-d distance_file -m matrix_file -R R_output_prefix -out output.err -log file.log} [options]
Requires the addition of the R module prior to running (i.e. module add R/2.12.1)

{} indicates required input (order unimportant)
[] indicates optional input (order unimportant)

This program is designed to identify sequencing errors and sequences that can not be distinguished from sequencing error in Illumina data.
It identifies sequencing error by looking for a parent for each sequence, starting with the most abundant across libraries in your matrx file.
Parents are sequences that satisfies the following:
1.) The parental abundance is above the defined the abundance threshold
2.) It is within a specific distance cut-off
3.) The parental distribution is not statistically significantly different from the child distribution as determined by fisher (when possible), or chi-sq test above the pvalue threshold

A child is assigned to the most similar (smallest distance) parental sequence that fulfills the above criteria.
Once assigned as a child, a sequence will not be considered as a parent.

Example usage:
perl find_seq_errors22_2.pl -d file.dst -m file.mat -R R_file -out output.err -log file.log

Options:
    -d distance_file          A distance file, or list of distance files (i.e. aligned and unaligned) separated by commas
    -m matrix_file            The distribition of this sequence (a.k.a. 100% identity cluster) across your libraries
    -R R_output_prefix        The output prefix used for the R_files (requires R/2.12.1, make sure to add this module before running this program
    -out output.err           The output file name containing the a list of errors and to be parsed into a typical OTU file format by err2list.pl
    -log LOGFILE              Name of the log file where some information will be logged
    -old old_err_files        If this program did not complete upon running it previous, this provides a way to pick up where the last program left off
    -dist DIST                The distance cutoff that you would consider merging sequences to (default is 0.1)
    -abund ABUND              The abundance cutoff that a parent has to satisfy to be considered. 
                              0 if you want to merge uninformative sequence diversity, 10 is about the largest you should use (since it corresponds to your error rate)
    -pval PVALUE              P-value cutoff above which will be merged. Default=0.0005
			      Lower pvalues will keep more things separate, higher pvalues will merge more things.
\n" unless (@ARGV);

$j=@ARGV;
$i=0;

until ($i >= $j){
    $k=$i+1;
    if ($ARGV[$i] eq "-d"){
       $distfiles=$ARGV[$k];
    } elsif ($ARGV[$i] eq "-m"){
       $matfile=$ARGV[$k];
    } elsif ($ARGV[$i] eq "-R"){
       $Rfile=$ARGV[$k];
    } elsif ($ARGV[$i] eq "-out"){
       $output=$ARGV[$k];
    } elsif ($ARGV[$i] eq "-log"){
       $logfile = $ARGV[$k];
    } elsif ($ARGV[$i] eq "-old"){
       $oldstats=$ARGV[$k];
    } elsif ($ARGV[$i] eq "-dist"){
       $distcutoff=$ARGV[$k];
       $gotdistcutoff++;
    } elsif ($ARGV[$i] eq "-abund"){
       $abundcutoff=$ARGV[$k];
       $gotabundcutoff++;
    } elsif ($ARGV[$i] eq "-pval"){
       $pvaluecutoff=$ARGV[$k];
       $gotpvaluecutoff++;
    } elsif ($ARGV[$i] eq "-h" || $ARGV[$i] eq "--help" || $ARGV[$i] eq "-help"){
       exit printHelp ();
    }
    $i++;
}
die "Please follow command line args
Output: ${output}
distfiles:$distfiles
matfile:$matfile
Rfile:$Rfile
logfile:$logfile\n" unless ($output && $distfiles && $matfile && $Rfile && $logfile);
chomp ($distfiles);
chomp ($matfile);
chomp ($Rfile);
chomp ($oldstats) if ($oldstats);
chomp ($output);
chomp ($logfile);
$programname="find_seq_errors22_2.pl";
open (OUT, ">${Rfile}.lic") or die "Can't open ${Rfile}.lic\n";
print OUT "license()\n";
close (OUT);
$licinfo= `R --slave --vanilla --silent < '${Rfile}'.lic`;
unless ($licinfo=~/GNU/){
   die "R module not functional, please make R avaiable by loading the module as such:
module add R/2.12.1\n";
}

open (LOG, ">${logfile}") or die "Can't open ${logfile}\n";
#define your cutoffs
$pvaluecutoff=0.0005 unless ($gotpvaluecutoff);
$distcutoff=0.2 unless ($gotdistcutoff);
$abundcutoff=10 unless ($gotabundcutoff);
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
$newyear = $year+1900;
$newmonth=$mon+1;
$lt= "$newmonth-$mday-$newyear $hour:$min:$sec";

print LOG "Running: ${programname}
Time:$lt
Input:$distfiles
Distributions:$matfile
Routput:$Rfile
Pvalue cutoff:$pvaluecutoff
Distance cutoff:${distcutoff}
Abundance cutoff:${abundcutoff}
Output:$output
Old Stats:";
    if ($oldstats){
	print LOG "$oldstats\n";
    } else {
	print LOG "None\n";
    }

print LOG "R license Info:
$licinfo\n";

#record library distribution data
if ($oldstats){
    $init=();
    open (IN, "<$oldstats" ) or die "Can't open $oldstats\n";
    while ($line =<IN>){
	chomp ($line);
	next unless ($line);
	if ($line=~/Changefrom,.+,.+,Changeto/){
	    ($id, $oid)=$line=~/Changefrom,(.+),(.+),Changeto/;
	    $parenthash{$oid}++;
	    $childhash{$id}++;
	} elsif ($line=~/Finished Alignment/){
	    $skipalignment++;
	} elsif ($line=~/Done testing as child/){
	    ($oid)=$line=~/^(.+): Done testing as child/;
	    $donehash{$oid}++;
	}
    }
    close (IN);
} else {
    $init=1;
}

open (IN, "<$matfile" ) or die "Can't open $matfile\n";
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @libs) =split ("\t", $line);
    if ($first){
	$first=();
	(@headers)=@libs;
    } else {
	$i=0;
	$j=@headers;
	$total=0;
	until ($i>=$j){
	    $mathash{$OTU}{$headers[$i]}=$libs[$i] if ($headers[$i]);
	    $matbarhash{$headers[$i]}++ if ($headers[$i]);
	    $total+=$libs[$i];
	    $i++;
	}
	$abundhash{$OTU}=$total;
    }
      
}
close (IN);

#now parse the distance files
(@distarray)=split (",", $distfiles);
foreach $file (@distarray){
    ($answer)=dst2tab ($file, $distcutoff);
    die "Didn't finish distance\n" unless ($answer eq "Finished");
}

open (OUT, ">${output}") or die "Can't open $output\n";

#make the program files that R will use to run the Fisher exact and Chi square tests
makeRexecutables ();

#start the error processing
foreach $oid (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
    if ($init){
	#this is the most abundant one, see if it clears the threshold
	#otherwise, if you have singletons, they will all be seperate OTUs
	#because the most abundant one isn't even above the threshold
	if ($abundhash{$oid} < ${abundcutoff}){
	    $mergeall=1;
	    $allparent=$oid;
	} else {
	    $mergeall=();
	}
	$init=();
    }
    %resabundhash=();
    #in this step we want to find things that are less abundant and look at all of the things that are closely related
    #Take the distribution of chisq values and find the best one
    #next unless ($examplehash{$oid});
    next if ($parenthash{$oid} || $donehash{$oid});
    #print OUT "OID: $oid $abundhash{$oid}\n";
    foreach $id (sort {$disthash{$oid}{$a} <=> $disthash{$oid}{$b}} keys %{$disthash{$oid}}){
	#only evaluate things that have a distance in the file (some files are too long to keep all pairs)
	next unless ($gotdist{$oid}{$id});
	if ($mergeall){
	    unless ($oid eq $allparent){
		print OUT "Changefrom,${oid},${allparent},Changeto,DIST,MERGEALL,PVAL,MERGEALL,Done\n";
	    }
	    last;
	} else {
	    #only evaluate things that are at higher abundance, not already changed and not to distant
	    next if ($id eq $oid);
	    next if (${abundcutoff}*$abundhash{$oid} > $abundhash{$id});
	    next if ($disthash{$oid}{$id} > $distcutoff);
	    next if ($childhash{$id});
	    #check to see if the alignment is the only thing that is different between these sequences
	    #make a gapless sequence
	    #check if the distributions are the same across libraries
	    $totalnolib=0;
	    $string=();
	    $change=0;
	    $pvalue=();	
	    foreach $bar (sort keys %matbarhash){
		#don't print, but pass something to R
		$mathash{$oid}{$bar} = 0 unless ($mathash{$oid}{$bar});
		$mathash{$id}{$bar} =0 unless ($mathash{$id}{$bar});
		if ($mathash{$oid}{$bar} || $mathash{$id}{$bar}){
		    if ($string){
			$string="$string"."$mathash{$oid}{$bar}\t$mathash{$id}{$bar}\n";
		    } else {
			$string="$mathash{$oid}{$bar}\t$mathash{$id}{$bar}\n";
		    }
		    $totalnolib++ if ($mathash{$oid}{$bar} || $mathash{$id}{$bar});
		}
	    }
	    if ($totalnolib ==1){
		#print "they are in one library\n";
		#if they are both only found in one library, combine them
		$pvalue=1;
		$change++;
	    } else {
		#run chisq and fishers
		system ("rm ${Rfile}.fisp\n") if (-e "${Rfile}.fisp");
		system ("rm ${Rfile}.chip\n") if (-e "${Rfile}.chip");
		system ("rm ${Rfile}.chiexp\n") if (-e "${Rfile}.chiexp");
		system ("rm ${Rfile}.chisimp\n") if (-e "${Rfile}.chisimp");
		$fpvalue=();
		$cpvalue=();
		$spvalue=();
		$manpvalue=();
		open (INPUT, ">${Rfile}.in") or die "Can't open ${Rfile}.in\n";
		print INPUT "$string\n";
		close (INPUT);
		system ("R --slave --vanilla --silent < ${Rfile}.fis >> ${Rfile}.err");		    
		if (-e "${Rfile}.fisp"){
		    $fpvalue=();
		    open (RES, "<${Rfile}.fisp") or die "Can't open ${Rfile}.fisp\n";
		    while ($Rline=<RES>){
			chomp ($Rline);
			next unless ($Rline);
			($fpvalue)=$Rline=~/^(.+)/;
		    }
		    close (RES);
		    $pvalue=$fpvalue;
		    $gotpvalue++;
		} else {
		    #now try chisq
		    $cpvalue=();
		    system ("R --slave --vanilla --silent < ${Rfile}.chi >> ${Rfile}.err");
		    $gotchip=0;
		    if (-e "${Rfile}.chip"){
			$gotchip=1;
			open (RES, "<${Rfile}.chip") or die "Can't open ${Rfile}.chip\n";
			while ($Rline=<RES>){
			    chomp ($Rline);
			    ($cpvalue)=$Rline=~/^(.+)/;
			}
			close (RES);
		    } else {
			#print "Missing .chip\n";
		    }
		    #now get expected
		    if (-e "${Rfile}.chiexp"){
			open (RES, "<${Rfile}.chiexp") or die "Can't open ${Rfile}.chiexp\n";
			while ($Rline=<RES>){
			    chomp ($Rline);
			    next unless ($Rline);
			    (@retpie)=split ("\n", $Rline);
			}
			close (RES);
			foreach $pie (@retpie){
			    if ($pie=~/^(.+)\t(.+)$/){
				($exp1, $exp2)=$pie=~/^(.+)\t(.+)$/;
				if ($exp1 > 5){
				    $hightot++;
				}
				if ($exp2 > 5){
				    $hightot++;
				}
				$exptot+=2;
			    }
			}
			$expercent=$hightot/$exptot if ($exptot);
			#can't use chisq when expected values are too low because results are wrong

			if ($expercent<0.8){
			    #if the expected values are too low
			    #then the chisq will be incorrect, simulate pvalue with monte carlo simulation
			    system ("R --slave --vanilla --silent < ${Rfile}.chisim >> ${Rfile}.err");
			    $spvalue=();
			    if (-e "${Rfile}.chisimp"){
				#print "got chipsimp\n";
				open (RES, "<${Rfile}.chisimp") or die "Can't open ${Rfile}.chisimp\n";
				while ($Rline=<RES>){
				    chomp ($Rline);
				    next unless ($Rline);
				    #print "Rline chisimp $Rline\n";
				    ($spvalue)=$Rline=~/^(.+)/;
				}
				close (RES);
			    }
			    $pvalue=$spvalue;
			    $gotpvalue++;
			} elsif ($gotchip){
			    #just go with the calculated pvalue
			    $pvalue=$cpvalue;
			    $gotpvalue++;
			} else {
			    #print "Missing all values: $oid $id\n";
			}
		    } else {
			#print "Missing chisq too\n";
		    }
		}
	    }
	    #print "Recording Pvalue $oid $id Pvalue:${pvalue}\n";
	    #print OUT "Evaluating $id\n";
	    if ($pvalue > $pvaluecutoff){
		unless ($mergeall){
		    print OUT "Changefrom,$oid,$id,Changeto,DIST,$disthash{$oid}{$id},PVAL,$pvalue,Done\n";
		    #when it's assigned as a parent, don't evalualte as a child                                                                                                                              
		    $parenthash{$id}++;
		    #when it's assigned as a child, don't evaluate as a parent                                                                                                                               
		    $childhash{$oid}++;
		    last;
		}
	    }
	}
    }
    print OUT "$oid: Done testing as child\n";
}

print OUT "Finished\n";
close (OUT);

############
#subroutines
############

sub dst2tab {
    my ($file, $cutoff) = (@_);
    my (%done);
    my (%isolatehash);
    my (%translatehash2);
    my ($line);
    my (@pieces);
    my ($isolate);
    my ($distance);
    chomp ($file);
    $k=1;
    open (IN, "<$file") or die "Can't open $file\n";
    while ($line=<IN>){
	chomp ($line);
	(@pieces) = split (" ", $line);
	if ($pieces[0] =~/[A-z]/){
	    ($isolate) = shift (@pieces);
	    $j=1;
	    $translatehash2{$k}=$isolate;
	    $k++;
	}
	
	foreach $distance (@pieces){
	    next unless ($distance && $isolate);
	    $isolatehash{$isolate}{$j}=$distance if ($distance <= $cutoff);
	    $j++;
	}
	
    }
    
    foreach $isolate (sort keys %isolatehash){
	foreach $oisono (sort keys %{$isolatehash{$isolate}}){
	    next if ($isolate eq $translatehash2{$oisono});
	    next if ($done{$isolate}{$translatehash2{$oisono}} || $done{$translatehash2{$oisono}}{$isolate});
	    $done{$isolate}{$translatehash2{$oisono}}++;
	    if ($disthash{$isolate}{$translatehash2{$oisono}} || $disthash{$translatehash2{$oisono}}{$isolate}){
		#this already exists, so only replace if the new value is less
		if ($disthash{$isolate}{$translatehash2{$oisono}}){
		    if ($disthash{$isolate}{$translatehash2{$oisono}}>$isolatehash{$isolate}{$oisono}){
			$disthash{$isolate}{$translatehash2{$oisono}}=$isolatehash{$isolate}{$oisono};
		    }
		}
		if ($disthash{$translatehash2{$oisono}}{$isolate}){
		#this already exists, so only replace if the new value is less
		    if ($disthash{$translatehash2{$oisono}}{$isolate}>$isolatehash{$isolate}{$oisono}){
			$disthash{$translatehash2{$oisono}}{$isolate}=$isolatehash{$isolate}{$oisono};
		    }
		}
	    } else {
		$disthash{$translatehash2{$oisono}}{$isolate}=$isolatehash{$isolate}{$oisono};
		$disthash{$isolate}{$translatehash2{$oisono}}=$isolatehash{$isolate}{$oisono};
		$gotdist{$isolate}{$translatehash2{$oisono}}++;
		$gotdist{$translatehash2{$oisono}}{$isolate}++;
	    }
	}
    }
    $result= "Finished";
    return ($result);
}

sub makeRexecutables {
    open (FIS, ">${Rfile}.fis") or die "Can't open ${Rfile}.fis\n";
    print FIS "x <- read.table(\"${Rfile}.in\", header = FALSE)
htest1<-fisher.test(x)
fisp <-htest1\$p.value
write.table(fisp,file=\"${Rfile}.fisp\",sep=\"\t\",row.names=FALSE,col.names=FALSE)\n";
    close (FIS);
    open (FIS, ">${Rfile}.chi") or die "Can't open ${Rfile}.chi\n";
    print FIS "x <- read.table(\"${Rfile}.in\", header = FALSE)
htest2 <-chisq.test(x)
chip <-htest2\$p.value
chiexp <-htest2\$expected
print(htest2)
write.table(chip,file=\"${Rfile}.chip\",sep=\"\t\",row.names=FALSE,col.names=FALSE)
write.table(chiexp,file=\"${Rfile}.chiexp\",sep=\"\t\",row.names=FALSE,col.names=FALSE)\n";
    close (FIS);
    open (FIS, ">${Rfile}.chisim") or die "Can't open ${Rfile}.chisim\n";
    print FIS "x <- read.table(\"${Rfile}.in\", header = FALSE)
htest3 <-chisq.test(x,simulate.p.value = TRUE, B = 10000)
chisimp <-htest3\$p.value
print(htest3)
write.table(chisimp,file=\"${Rfile}.chisimp\",sep=\"\t\",row.names=FALSE,col.names=FALSE)\n";
    
}

sub printHelp {
print "Usage: perl find_seq_error22_2.pl {-d distance_file -m matrix_file -R R_output_prefix -out output.err -log file.log} [options]                                                           
Requires the addition of the R module prior to running (i.e. module add R/2.12.1)                                                                                                                                                                                                      
{} indicates required input (order unimportant)                                                                                                                                                       
[] indicates optional input (order unimportant)                                                                                                                                                       
                                                                                                                                                                                                      
This program is designed to identify sequencing errors and sequences that can not be distinguished from sequencing error in Illumina data.                                                            
It identifies sequencing error by looking for a parent for each sequence, starting with the most abundant across libraries in your matrx file.                                                        
Parents are sequences that satisfies the following:                                                                                                                                                   
1.) The parental abundance is above the defined the abundance threshold                                                                                                                               
2.) It is within a specific distance cut-off                                                                                                                                                          
3.) The parental distribution is not statistically significantly different from the child distribution as determined by fisher (when possible), or chi-sq test above the pvalue threshold             
                                                                                                                                                                                                      
A child is assigned to the most similar (smallest distance) parental sequence that fulfills the above criteria.                                                                                       
Once assigned as a child, a sequence will not be considered as a parent.                                                                                                                              
                                                                                                                                                                                                      
Example usage:                                                                                                                                                                                        
perl find_seq_errors22_2.pl -d file.dst -m file.mat -R R_file -out output.err -log file.log                                                                                                           
                                                                                                                                                                                                      
Options:                                                                                                                                                                                              
    -d distance_file          A distance file, or list of distance files (i.e. aligned and unaligned) separated by commas                                                                             
    -m matrix_file            The distribition of this sequence (a.k.a. 100% identity cluster) across your libraries                                                                                  
    -R R_output_prefix        The output prefix used for the R_files (requires R/2.12.1, make sure to add this module before running this program                                                     
    -out output.err           The output file name containing the a list of errors and to be parsed into a typical OTU file format by err2list.pl                                                     
    -log LOGFILE              Name of the log file where some information will be logged                                                                                                              
    -old old_err_files        If this program did not complete upon running it previous, this provides a way to pick up where the last program left off                                               
    -dist DIST                The distance cutoff that you would consider merging sequences to (default is 0.1)                                            
";
}
