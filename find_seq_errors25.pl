#! /usr/bin/perl -w
#   Edited on 04/02/12 
#
$programname="find_seq_errors25.pl";

	die dieHelp () unless (@ARGV); 

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
   } elsif ($ARGV[$i] eq "-correl"){
       $correlcutoff=$ARGV[$k];
       $gotcorrelcutoff++;
   } elsif ($ARGV[$i] eq "-JSdiv"){
       $JScutoff=$ARGV[$k];
       $gotJScutoff++;
   } elsif ($ARGV[$i] eq "-SSEC"){
       $ssecfiles=$ARGV[$k];
       $gotssec++;
       ($ssecmat, $ssecfa)=split (",", $ssecfiles);
   } elsif ($ARGV[$i] eq "-onlySSEC"){
       $onlyssec++;
   } elsif ($ARGV[$i] eq "-verbose"){
       $verbose++;
    } elsif ($ARGV[$i] eq "-h" || $ARGV[$i] eq "--help" || $ARGV[$i] eq "-help"){
       exit dieHelp ();
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

#check requirements: R is required
open (OUT, ">${Rfile}.lic") or die "Can't open ${Rfile}.lic\n";
print OUT "license()\n";
close (OUT);
$licinfo= `R --slave --vanilla --silent < '${Rfile}'.lic`;
unless ($licinfo=~/GNU/){
   die "R module not functional, please make R avaiable by loading the module as such:
module add R/2.12.1
or equivalent before running\n";
}
#check requirements: SSSE
#using onlySSSE flag requires the mat and fa files and oldstats
if ($onlyssec){
    die "Missing parameters with onlySSEC: needed SSEC_mat and SSEC_fa files and old stats
Oldstats: $oldstats
SSEC_MAT: $ssecmat
SSEC_FA: $ssecfa\n" unless ($ssecmat && $ssecfa && $oldstats);
}
open (LOG, ">${logfile}") or die "Can't open ${logfile}\n";
#define your cutoffs
$pvaluecutoff=0.0005 unless ($gotpvaluecutoff);
$distcutoff=0.2 unless ($gotdistcutoff);
$abundcutoff=10 unless ($gotabundcutoff);
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
$isdst="NA";
$wday="NA";
$yday="NA";
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
print LOG "Use Correlation: $correlcutoff\n" if ($gotcorrelcutoff);
print LOG "Use KLdiv: $JScutoff\n" if ($gotJScutoff);
print LOG "Running only sequence-specific error correction\n" if ($onlyssec);
print LOG "Sequence specific error correcting files: mat- $ssecmat fasta- $ssecfa on $oldstats\n" if ($gotssec);
#record library distribution data
close (LOG);

if ($oldstats){
    $init=();
    if ($verbose){
	open (LOG, ">>${logfile}") or die "Can't open ${logfile}\n";
	print LOG "Reading in oldstats file: $oldstats\n";
	close (LOG);
    }
    open (IN, "<$oldstats" ) or die "Can't open $oldstats\n";
    while ($line =<IN>){
	chomp ($line);
	next unless ($line);
	if ($line=~/Changefrom,.+,.+,Changeto/){
	    ($id, $oid)=$line=~/Changefrom,(.+),(.+),Changeto/;
	    $parenthash{$oid}++;
	    $childhash{$id}++;
	} elsif ($line=~/Done testing as child/){
	    ($oid)=$line=~/^(.+): Done testing as child/;
	    $donehash{$oid}++;
	}
    }
    close (IN);
} else {
    $init=1;
}

if ($verbose){
    open (LOG, ">>${logfile}") or die "Can't open ${logfile}\n";
    print LOG "Reading in matfile file: $matfile\n";
    close (LOG);
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
if ($verbose){
    open (LOG, ">>${logfile}") or die "Can't open ${logfile}\n";
    print LOG "Reading in dist files: $distfiles\n";
    close (LOG);
}
(@distarray)=split (",", $distfiles);
foreach $file (@distarray){
    ($answer)=dst2tab ($file, $distcutoff);
    die "Didn't finish distance\n" unless ($answer eq "Finished");
}

open (OUT, ">${output}") or die "Can't open $output\n";

#make the program files that R will use to run the Fisher exact, Chi Square and Correlation tests
makeRexecutables ();
if ($verbose){
    open (LOG, ">>${logfile}") or die "Can't open ${logfile}\n";
    print LOG "Checking for seq errors\n";
    close (LOG);
}
#start the error processing
if ($onlyssec){
    ($nothing)= runssec();
} else {
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
	#in this step we want to find things that are less abundant and look at all of the things that are closely related
	#Take the distribution of chisq values and find the best one
	#next unless ($examplehash{$oid});
	next if ($parenthash{$oid} || $donehash{$oid});
	#look for possible parents
	foreach $id (sort {$disthash{$oid}{$a} <=> $disthash{$oid}{$b}} keys %{$disthash{$oid}}){
	    #only change to something than or equal to current abundance
	    next unless ($abundhash{$oid} <= $abundhash{$id});
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
		} else {
		    #although the pvalue suggests splitting, only split if the JS and/or correl is below cutoff
		    if ($gotJScutoff && $gotcorrelcutoff){
			($JSvalue)=JS_value($id, $oid);
			($correl)=findcorrel($id, $oid);
			if ($JSvalue > $JScutoff && $correl > $correlcutoff){
			    print OUT "Changefrom,$oid,$id,Changeto,DIST,$disthash{$oid}{$id},PVAL,$pvalue,JSdiv,$JSvalue,Correl,$correl,Done\n";
			    $parenthash{$id}++;
			    $childhash{$oid}++;
			    last;
			}
		    } elsif ($gotJScutoff){
			($JSvalue)=JS_value($id, $oid);
			if ($JSvalue > $JScutoff){
			    print OUT "Changefrom,$oid,$id,Changeto,DIST,$disthash{$oid}{$id},PVAL,$pvalue,JSdiv,$JSvalue,Done\n";
			    $parenthash{$id}++;
			    $childhash{$oid}++;
			    last;
			}
		    } elsif ($gotcorrelcutoff){
			($correl)=findcorrel($id, $oid);
			if ($correl> $correlcutoff){
			    print OUT "Changefrom,$oid,$id,Changeto,DIST,$disthash{$oid}{$id},PVAL,$pvalue,Correl,$correl,Done\n";
			    $parenthash{$id}++;
			    $childhash{$oid}++;
			    last;
			}
		    }
		}
	    }
	}
	print OUT "$oid: Done testing as child\n";
    }
    if ($gotssec){
	($nothing)=runssec();
    }
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
write.table(chip,file=\"${Rfile}.chip\",sep=\"\t\",row.names=FALSE,col.names=FALSE)
write.table(chiexp,file=\"${Rfile}.chiexp\",sep=\"\t\",row.names=FALSE,col.names=FALSE)\n";
    close (FIS);
    open (FIS, ">${Rfile}.chisim") or die "Can't open ${Rfile}.chisim\n";
    print FIS "x <- read.table(\"${Rfile}.in\", header = FALSE)
htest3 <-chisq.test(x,simulate.p.value = TRUE, B = 10000)
chisimp <-htest3\$p.value
write.table(chisimp,file=\"${Rfile}.chisimp\",sep=\"\t\",row.names=FALSE,col.names=FALSE)\n";
}

sub dieHelp {

die "Usage: perl $programname {-d distance_file -m matrix_file -R R_output_prefix -out output.err -log file.log} [options]
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
perl $programname -d file.dst -m file.mat -R R_file -out output.err -log file.log

Options:
    -d distance_file          A distance file, or list of distance files (i.e. aligned and unaligned) separated by commas
    -m matrix_file            The distribition of this sequence (a.k.a. 100% identity cluster) across your libraries
    -R R_output_prefix        The output prefix used for the R_files (requires R/2.12.1, make sure to add this module before running this program
    -out output.err           The output file name containing the a list of errors and to be parsed into a typical OTU file format by err2list.pl
    -log LOGFILE              Name of the log file where some information will be logged
    -old old_err_files        If this program did not complete upon running it previous, this provides a way to pick up where the last program left off
    -dist DIST_CUTOFF         The distance cutoff that you would consider merging sequences to (default is 0.1)
    -abund ABUND_CUTOFF       The abundance cutoff that a parent has to satisfy to be considered. 
                              0 if you want to merge uninformative sequence diversity, 10 is about the largest you should use (since it corresponds to your error rate)
    -pval PVALUE_CUTOFF       P-value cutoff above which will be merged. Default=0.0005
								          Lower pvalues will keep more things separate, higher pvalues will merge more things.
    -correl CORR_CUTOFF       Use the correlation to determine whether to merge values (default=off), especially when ABUND_CUTOFF = 0. 
                              Good correlation cutoff = 0.8
    -JS JS_CUTOFF             Use the Jensen-Shannon diistance to determine whether to merge values (default=off), especially when ABUND_CUTOFF = 0.
                              Good JS_CUTOFF value around 0.2 (best to use when abundance thresh = 0)
    -SSEC SSEC_MAT,FA         Correct for sequence specific sequencing errors which might be prevalent in poor quality runs. Provide the count matrix 
                              and fasta files made from the raw data (completely unfiltered) by running the raw data through a similar pipeline as with processed data.
    -verbose                  Print out verbose information about progress to log file. Useful in debugging.
\n";
}

sub JS_value {
    #pass the two OTUs that you want to compare
    #need to have matbarhash defined with all of the 
    #header values in the library
    #also need mathash defined with the count of each OTU across all libraries

    my ($one);
    my ($two);
    my ($JS1);
    $JS1=0;
    my ($JS2);
    $JS2=0;
    my ($newJS);
    $newJS=0;
    my ($q);
    my ($p);
    my ($header);
    ($one, $two) = @_;
    foreach $header (sort keys %matbarhash){
	    #each is defined as the portion of the 
	if ($mathash{$one}{$header}){
	    ($p) = $mathash{$one}{$header}/$totalhash{$one};
	} else {
	    $p=0;
	}
	if ($mathash{$two}{$header}){
	    ($q) = $mathash{$two}{$header}/$totalhash{$two};
	} else {
	    $q=0;
	}
	if (($q > 0) && ($p > 0)){
	    #first make the KL of x,(x+y)/2
	    $JS1+=($p*(log($p/(($p+$q)/2))));
	    $JS2+=($q*(log($q/(($q+$p)/2))));
	}
    }
    $newJS=($JS1 + $JS2)/2;
    return ($newJS);
}

sub findcorrel {
    #%matbarhash must be defined and contain the keys of all possible libraries
    #%mathash must be defined and contain the values of each OTU across all libraries
    #R must be loaded and running
    my ($one, $two);
    ($one, $two) = @_;
    my ($string);
    $string=();
    my ($totalnolib);
    $totalnolib=();
    my ($correl);
    foreach $bar (sort keys %matbarhash){
	#don't print, but pass something to R
	$mathash{$two}{$bar} = 0 unless ($mathash{$two}{$bar});
	$mathash{$one}{$bar} =0 unless ($mathash{$one}{$bar});
	if ($mathash{$two}{$bar} || $mathash{$one}{$bar}){
	    if ($string){
		$string="$string"."$mathash{$two}{$bar}\t$mathash{$one}{$bar}\n";
	    } else {
		$string="$mathash{$two}{$bar}\t$mathash{$one}{$bar}\n";
	    }
	    $totalnolib++ if ($mathash{$two}{$bar} || $mathash{$one}{$bar});
	}
    }
    if ($totalnolib ==1){
	$correl="NA";
    } else {
	system ("rm ${Rfile}.corv\n") if (-e "${Rfile}.corv");
	#run chisq and fishers
	open (INPUT, ">${Rfile}.in") or die "Can't open ${Rfile}.in\n";
	print INPUT "$string\n";
	close (INPUT);
	open (FIS, ">${Rfile}.cor") or die "Can't open ${Rfile}.cor\n";
	print FIS "x <- read.table(\"${Rfile}.in\", header = FALSE)                                                                                        
a<-x[1:${totalnolib},1]                                                                                               
b<-x[1:${totalnolib},2]                                                                                                                                                         
j<-cor(a,b)                                                                               
print(j)
write.table(j,file=\"${Rfile}.corv\",sep=\"\t\",row.names=FALSE,col.names=FALSE)\n";
	close (FIS);

	system ("R --slave --vanilla --silent < ${Rfile}.cor >> ${Rfile}.err");

	if (-e "${Rfile}.corv"){
	    $correl=();
	    my ($Rline);
	    open (RES, "<${Rfile}.corv") or die "Can't open ${Rfile}.corv\n";
	    while ($Rline=<RES>){
		chomp ($Rline);
		next unless ($Rline);
		($correl)=$Rline=~/^(.+)$/;
	    }
	    close (RES);
	} else {
	    die "${Rfile}.corv not available\n";
	}
    }
    return ($correl);

}

sub runssec {
#this subroutine tries to find sequence specific errors which can be especially important in poor quality runs.
#begins by reading in the raw data from ssecmat and ssecfa
#For sequences that are not present at all in the filtered data, it is assigned as an error to the nearest neighbor parent seqeunces 
#if that is within the pre-definied genetic cutoff because the sequences that are removed with more filtering are more likely to arise by sequencing error.
#For sequences that are present in the final dataset, a comparison of the counts across all libraries are made. 
#Sequences that are more dramatically affected are changed to the clos
#To determine whether this is an important flag to run, check to see how many sequences are lost with increased filtering.
#If you have lost more than 10% of the reads between your final quality (Q?) and the raw data, sequence specific sequencing errors might occur
#If seqeunce specific sequences errors have occurred, relative abundances between OTUs will be skewed, but can be corrected using this program
}
