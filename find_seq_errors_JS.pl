#! /usr/bin/perl -w
#   Edited on 04/02/12 
#
$programname="find_seq_errors26.pl";

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
       $usechisq++;
       die "Only choose -JS or -pval not both\n" if ($useJSdiv);
   } elsif ($ARGV[$i] eq "-JS"){
       $useJSdiv++;
       die "Only choose -JS or -pval not both\n" if ($usechisq);
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
die "Please choose which method to evaluate things JS or chisq\n" unless ($useJSdiv || $usechisq);
chomp ($distfiles);
chomp ($matfile);
chomp ($Rfile);
chomp ($oldstats) if ($oldstats);
chomp ($output);
chomp ($logfile);

if ($usechisq){
#check requirements: R is required
    open (OUT, ">${Rfile}.lic") or die "Can't open ${Rfile}.lic\n";
    print OUT "license()\n";
    close (OUT);
    $licinfo= `R --slave --vanilla --silent < '${Rfile}'.lic`;
    unless ($licinfo=~/GNU/){
	die "R module not functional, please make R avaiable by loading the module as such:
module add R/2.12.1
or equivalent before running
$licinfo
 ${Rfile}.lic\n";
    }
}
open (LOG, ">${logfile}") or die "Can't open ${logfile}\n";
#define your cutoffs
if ($usechisq){
    $pvaluecutoff=0.0005 unless ($gotpvaluecutoff);
}
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
Distance cutoff:${distcutoff}
Abundance cutoff:${abundcutoff}
Output:$output
Old Stats:";
    if ($oldstats){
	print LOG "$oldstats\n";
    } else {
	print LOG "None\n";
    }
if ($usechisq){
    print LOG "R license Info:
$licinfo
Pvaluecutoff: $pvaluecutoff\n";
}
print LOG "Use JSdiv\n" if ($useJSdiv);
#record library distribution data

if ($oldstats){
    $init=();
    print LOG "Reading in oldstats file: $oldstats\n" if ($verbose);
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

print LOG "Reading in matfile file: $matfile\n" if ($verbose);

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
    print LOG "Reading in dist files: $distfiles\n" if ($verbose);

(@distarray)=split (",", $distfiles);
foreach $file (@distarray){
    print LOG "Reading in dist file: $file\n" if ($verbose);
    ($answer)=dst2tab ($file);
    die "Didn't finish distance\n" unless ($answer eq "Finished");
}

open (OUT, ">${output}") or die "Can't open $output\n";

#make the program files that R will use to run the Fisher exact, Chi Square and Correlation tests
makeRexecutables ();
if ($verbose){
    open (LOG, ">>${logfile}") or die "Can't open ${logfile}\n";
    print LOG "Checking for seq errors\n";
}
#start the error processing
$init=1;
foreach $oid (sort {$abundhash{$b} <=> $abundhash{$a}} keys %abundhash){
    print LOG "Working on $oid\n" if ($verbose);
    if ($init){
	print LOG "Evaluating mergeall situation: $init\n" if ($verbose);
	#this is the most abundant one, see if it clears the threshold
	#otherwise, if you have singletons, they will all be seperate OTUs
	#because the most abundant one isn't even above the threshold
	if ($abundhash{$oid} < ${abundcutoff}){
	    $mergeall=1;
	    $allparent=$oid;
	    print LOG "All will be merged into $oid\n" if ($verbose); 
	} else {
	    $mergeall=();
	    print LOG "Not under mergeall conditions\n" if ($verbose);
	}
	$init=();
    }
    #in this step we want to find things that are less abundant and look at all of the things that are closely related
    #Take the distribution of chisq values and find the best one
    #next unless ($examplehash{$oid});
    print LOG "Checking for doneness: $oid\n" if ($verbose);
    next if ($parenthash{$oid} || $donehash{$oid});
    print LOG "$oid was not previously done\n" if ($verbose);
    #look for possible parents beginning with the closest relative
    print LOG "Clearing distance hash $oid\n" if ($verbose);
    %wdisthash=();
    foreach $distfile (@distarray){
	print LOG "Reading in the distarray files for $oid\n" if ($verbose);
	if (@{$distarrayhash{$oid}{$distfile}}){
	    $j=@{$distarrayhash{$oid}{$distfile}};
	    $i=0;
	    print LOG "Recording $distfile distances in wdisthash for $oid\n" if ($verbose);
	    until ($i >=$j){
		$distance= ${$distarrayhash{$oid}{$distfile}}[$i];
		$otheriso=$translatehash2{$distfile}{$i};
		$wdisthash{$otheriso}=$distance unless ($otheriso eq $oid || $distance > $distcutoff || $abundhash{$oid} > $abundhash{$otheriso} || $childhash{$otheriso});
		$i++;
	    }
	} else {
	    die "No distarrayhash for $oid\n";
	}
    }
    %done=();
    foreach $id (sort {$wdisthash{$a} <=> $wdisthash{$b}} keys %wdisthash){
	#only change to something than or equal to current abundance
	print LOG "$id is the next closest sequence to $oid: $wdisthash{$id}\n" if ($verbose);
	next if ($done{$id});
	$done{$id}++;
	next unless ($abundhash{$oid} <= $abundhash{$id});
	print LOG "$id ($abundhash{$id}) passed abundance requirements for parent: more abundant than or equally abundant as $oid $abundhash{$oid}\n" if ($verbose);
	#only evaluate things that have a distance in the file (some files are too long to keep all pairs)
	if ($mergeall){
	    unless ($oid eq $allparent){
		print LOG "Under mergeall assumptions $oid changed to $allparent\n" if ($verbose);
		print OUT "Changefrom,${oid},${allparent},Changeto,DIST,MERGEALL,PVAL,MERGEALL,Done\n";
	    }
	    last;
	} else {
	    #only evaluate things that are at higher abundance, not already changed and not to distant
	    if ($id eq $oid){
		print LOG "FAILED: $id is the same as $oid\n";
		next;
	    }
	    if (${abundcutoff}*$abundhash{$oid} > $abundhash{$id}){
		print LOG "FAILED: $id didn't pass the abundance criteria of ${abundcutoff} * $abundhash{$oid} > $abundhash{$id}\n";
		next;
	    }
	    if ($wdisthash{$id} > $distcutoff){
		print LOG "FAILED: $id did not pass distance cut-off of $distcutoff $wdisthash{$id}\n";
		next;
	    }
	    if ($childhash{$id}){
		print LOG "FAILED: $id is already a child\n";
		next;
	    }
	    #check to see if the alignment is the only thing that is different between these sequences
	    #make a gapless sequence
	    #check if the distributions are the same across libraries
	    if ($useJSdiv){
		print LOG "Evaluating with JS $id $oid\n";
		#evaluate with JSdiv
		($JSvalue)=JS_value($id, $oid);
		($critical)=JS_boot($id, $oid);
		if ($JSvalue >= $critical){
		    die "Made it JS $id $oid $critical\n";
		    print OUT "Changefrom,$oid,$id,Changeto,DIST,$wdisthash{$id},PVAL,$pvalue,JSdiv,$JSvalue,Done\n";
		    print LOG "Changefrom,$oid,$id,Changeto,DIST,$wdisthash{$id},PVAL,$pvalue,JSdiv,$JSvalue,Done\n";
		    $parenthash{$id}++;
		    $childhash{$oid}++;
		    last;
		} else {
		    print LOG "Did not meet JS criteria $JSvalue $critical $id $oid\n";
		}
	    } elsif ($usechisq){
		#evaluate with chisq rules
		$totalnolib=0;
		$string=();
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
		$gotpvalue=();
		$pvalue=();
		if ($totalnolib ==1){
		    print LOG "$oid and $id are only in one library\n";
		    #if they are both only found in one library, combine them
		    $pvalue=1;
		    $gotpvalue++;
		} else {
		    #run chisq and fishers
		    system ("rm ${Rfile}.fisp\n") if (-e "${Rfile}.fisp");
		    system ("rm ${Rfile}.chip\n") if (-e "${Rfile}.chip");
		    system ("rm ${Rfile}.chiexp\n") if (-e "${Rfile}.chiexp");
		    system ("rm ${Rfile}.chisimp\n") if (-e "${Rfile}.chisimp");
		    $cpvalue=();
		    open (INPUT, ">${Rfile}.in") or die "Can't open ${Rfile}.in\n";
		    print INPUT "$string\n";
		    close (INPUT);
		    system ("R --slave --vanilla --silent < ${Rfile}.fis >> ${Rfile}.err");		    
		    #die "Finished fishers: check results in ${Rfile}.fisp\n";
		    if (-e "${Rfile}.fisp"){
			open (RES, "<${Rfile}.fisp") or die "Can't open ${Rfile}.fisp\n";
			while ($Rline=<RES>){
			    chomp ($Rline);
			    next unless ($Rline);
			    ($pvalue)=$Rline=~/^(.+)/;
			}
			close (RES);
			$gotpvalue++;
			print LOG "Got pvalue from fishers: $pvalue $id $oid\n" if ($verbose);
		    } else {
			#now try chisq
			$cpvalue=();
			system ("R --slave --vanilla --silent < ${Rfile}.chi >> ${Rfile}.err");
			$gotchip=0;
			if (-e "${Rfile}.chip"){
			    die "Got a chisq result: $id $oid ${Rfile}.chi ${Rfile}.chip\n";
			    $gotchip=1;
			    open (RES, "<${Rfile}.chip") or die "Can't open ${Rfile}.chip\n";
			    while ($Rline=<RES>){
				chomp ($Rline);
				($cpvalue)=$Rline=~/^(.+)/;
			    }
			    close (RES);
			} else {
			    print LOG "Missing .chip (chisq didn't run): $id $oid\n" if ($verbose);
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
				print LOG "$expercent value is less than the expected 0.8: try to simulate pvalue $id $oid\n" if ($verbose);
				system ("R --slave --vanilla --silent < ${Rfile}.chisim >> ${Rfile}.err");
				if (-e "${Rfile}.chisimp"){
				    print LOG "got chipsimp $id $oid\n" if ($verbose);
				    open (RES, "<${Rfile}.chisimp") or die "Can't open ${Rfile}.chisimp\n";
				    while ($Rline=<RES>){
					chomp ($Rline);
					next unless ($Rline);
					print LOG "Got pvalue from simulated chisq: $id $oid $pvalue\n" if ($verbose);
					($pvalue)=$Rline=~/^(.+)/;
					$gotpvalue++;
				    }
				    close (RES);
				}
			    } elsif ($gotchip){
				#just go with the calculated pvalue
				$pvalue=$cpvalue;
				$gotpvalue++;
				print LOG "Got the calculated pvalue for chisq: $id $oid $pvalue\n" if ($verbose);
			    }
			} else {
			    print LOG "Missing chisq file, trying chisimp: $id $oid\n" if ($verbose);
			    system ("R --slave --vanilla --silent < ${Rfile}.chisim >> ${Rfile}.err");
			    if (-e "${Rfile}.chisimp"){
				print LOG "got chipsimp $id $oid\n" if ($verbose);
				open (RES, "<${Rfile}.chisimp") or die "Can't open ${Rfile}.chisimp\n";
				while ($Rline=<RES>){
				    chomp ($Rline);
				    next unless ($Rline);
				    print LOG "Rline chisimp $Rline $id $oid\n" if ($verbose);
				    ($pvalue)=$Rline=~/^(.+)/;
				    $gotpvalue++;
				    print LOG "Got pvalue from simulated chisq: $id $oid $pvalue\n" if ($verbose);
				}
				close (RES);
			    } else {
				print LOG "Tried everything and couldn't get a pvalue from $id $oid\n" if ($verbose);
				#die "Could not get a pvalue for these: $id $oid\n";
			    }
			}
		    }
		}
		if ($gotpvalue){
		    if ($pvalue > $pvaluecutoff){
			print LOG "pvalue ($pvalue) is larger than the critical pvalue cutoff value ($pvaluecutoff): $id $oid\n" if ($verbose); 
			unless ($mergeall){
			    print OUT "Changefrom,$oid,$id,Changeto,DIST,$wdisthash{$id},PVAL,$pvalue,Done\n";
			    #when it's assigned as a parent, don't evalualte as a child                                                                                                                              
			    $parenthash{$id}++;
			    #when it's assigned as a child, don't evaluate as a parent                                                                                                                               
			    $childhash{$oid}++;
			    last;
			}
		    }
		} else {
		    print LOG "Didn't record a pvalue but tried: $id $oid\n";
		    #die "Didn't record a pvalue but tried: $id $oid\n";   
		}
	    }
	}
	if ($verbose){
	    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
	    $isdst="NA";
	    $wday="NA";
	    $yday="NA";
	    $newyear = $year+1900;
	    $newmonth=$mon+1;
	    $lt= "$newmonth-$mday-$newyear $hour:$min:$sec";
	    print LOG "$oid: Done testing as child\n$lt\n";
	}
	print OUT "$oid: Done testing as child\n";
    }
}
print OUT "Finished\n";
close (OUT);

############
#subroutines
############

sub dst2tab {
    my ($file) = (@_);
    my ($line);
    my (@pieces);
    my ($isolate);
    chomp ($file);
    $k=0;
    open (IN, "<$file") or die "Can't open $file\n";
    print LOG "Opened $file\n" if ($verbose);
    while ($line=<IN>){
	chomp ($line);
	(@pieces) = split (" ", $line);
	if ($pieces[0] =~/[A-z]/){
	    ($isolate) = shift (@pieces);
	    $translatehash2{$file}{$k}=$isolate;
	    @{$distarrayhash{$isolate}{$file}}=@pieces;
	    $k++;
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
    -dist DIST_CUTOFF         The distance cutoff that you would consider merging sequences to (default is 0.2)
    -abund ABUND_CUTOFF       The abundance cutoff that a parent has to satisfy to be considered. 
                              0 if you want to merge uninformative sequence diversity, 10 is about the largest you should use (since it corresponds to your error rate)
    -pval PVALUE_CUTOFF       Use fishers or if that doesn't work chisq or simulate the chisq test with R to determine a P-value (default=yes), and input 
                              cutoff above which will be merged. Default PVALUE_CUTOFF=0.0005. Lower pvalues will keep more things separate, higher pvalues will merge more things.
    -JS                       Use the Jensen-Shannon distance to determine whether to merge values (default=off), especially when ABUND_CUTOFF = 0.
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
	    if ($abundhash{$one}){
		($p) = $mathash{$one}{$header}/$abundhash{$one};
	    } else {
		die "No abundhash $one $abundhash{$one}\n";
	    }
	} else {
	    $p=0;
	}
	if ($mathash{$two}{$header}){
	    if ($abundhash{$two}){
		($q) = $mathash{$two}{$header}/$abundhash{$two};
	    } else {
		die "No abundhash for $two $abundhash{$two}\n";
	    }
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

sub JS_boot {
    #use this to bootstrap the JS_div value by doing it for 1000 replicates
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
    my ($critical);
    ($one, $two) = @_;
    #make an array of all the headers to mix-up
    unless ($headerarray){
	foreach $header (sort keys %matbarhash){
	    #make a random array for isolate one
	    push (@headerarray, $header);
	}               
    }
    $loopi=0;
    $loopend=1000;
    @resultsarray=();
    until ($loopi >=$loopend){
	#randomize the header array separately for each isolate
	(@randheader1)=randarray(@headerarray);
	(@randheader2)=randarray(@headerarray);
	#now record the randomized header as the same for both
	$j=@randheader1;
	$k=@randheader2;
	die "Rand header arrays aren't the same size $one $two\n" unless ($j == $k);
	$i=0;
	$JS1=();
	$JS2=();
	until ($i >=$j){
	    if ($mathash{$one}{$randheader1[$i]}){
		if ($abundhash{$one}){
		    ($p) = $mathash{$one}{$randheader1[$i]}/$abundhash{$one};
		} else {
		    die "No abundhash for $one $abundhash{$one}\n";
		}
		print LOG "$one,$i,$p,$randheader1[$i]\n";
	    } else {
		$p=0;
		print LOG "$one,$i,$p,$randheader1[$i]\n";
	    }
	    if ($mathash{$two}{$randheader2[$i]}){
		if ($abundhash{$two}){
		    ($q) = $mathash{$two}{$randheader2[$i]}/$abundhash{$two};
		} else {
		    die "Not abundhash for $two $abundhash{$two}\n";
		}
		print LOG "$one,$i,$q,$randheader2[$i]\n";
	    } else {
		$q=0;
		print LOG "$one,$i,$q,$randheader2[$i]\n";
	    }
	    if (($q > 0) && ($p > 0)){
		#first make the KL of x,(x+y)/2                                                                                                                                                 
		$JS1+=($p*(log($p/(($p+$q)/2))));
		$JS2+=($q*(log($q/(($q+$p)/2))));
	    } else {
		$JS1+=0;
		$JS2+=0;
	    }
	    $i++;
	}
	$newJS=($JS1 + $JS2)/2;
	push (@resultsarray, $newJS);
	$loopi++;
    }
    (@newarray)=sort (@resultsarray);
    $critical=$newarray[989];
    return ($critical);
}

sub randarray {
    my @array = @_;
    my @randarray = ();
    #pick an index at random
    $j=@array;
    $done=();
    %picked=();
    @randarray=();
    until ($done){
	#pick an index at rand
	($randval)=int(rand($j));
	if ($picked{$randval}){
	    #try again
	} else {
	    #got a rand value
	    #record it
	    $picked{$randval}++;
	    #now push that into a new array
	    push (@randarray, $array[$randval]);
	    #now check whether randarray has the same number of things as array
	    $k=@randarray;
	    if ($k == $j){
		$done++;
	    } elsif ($k > $j){
		die "Problem with randarry subroutine\n";
	    }
	}
    }
    return (@randarray);
}
