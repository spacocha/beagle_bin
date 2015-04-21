#! /usr/bin/perl -w
#
#

$programname="run_it_all_for_me.pl";

	dieHelp() unless (@ARGV);

chomp (@ARGV);
$j=@ARGV;
$i=0;

until ($i >= $j){
    $k=$i+1;
    if ($ARGV[$i] eq "-f"){
	$SOLFILEF=$ARGV[$k];
    } elsif ($ARGV[$i] eq "-o"){
	$OLIGO=$ARGV[$k];
    } elsif ($ARGV[$i] eq "-m"){
	$MAPFILE=$ARGV[$k];
    }elsif ($ARGV[$i] eq "-u"){
        $UNIQUE=$ARGV[$k];
    } elsif ($ARGV[$i] eq "-h" || $ARGV[$i] eq "--help" || $ARGV[$i] eq "-help"){
	exit dieHelp ();
    }
    $i++;
}


dieHelp () unless ($SOLFILEF && $OLIGO && $MAPFILE && $UNIQUE);

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
$isdst="NA";
$wday="NA";
$yday="NA";
$newyear = $year+1900;
$newmonth=$mon+1;
$lt= "$newmonth-$mday-$newyear $hour:$min:$sec";

print "Time started: $lt\n";

print "Estimating variables\n";

$vfile="${UNIQUE}.all_variables";
##########################
#create the variables file
##########################

open (OUT, ">${vfile}") or die "Can't open ${vfile}\n";
#bin which is accesible for most users of beagle
#place where the programs are found
$BIN="/data/spacocha/bin";
print OUT "#bin which is accesible for most users of beagle
#place where the programs are found
BIN=$BIN\n";
#unique name given as input
print OUT "#unique name given as input
UNIQUE=${UNIQUE}\n";
#filter out anything less than or equal to this amount
$FNUMBER=0;
print OUT "#filter out anything less than this amount
FNUMBER=${FNUMBER}\n";

#RUNQIIEM_RAWDATA
#where is the fastq file you want to process
print OUT "#fastq file
SOLFILEF=${SOLFILEF}\n";

#mapping file
print OUT "#where the multiple information lives
#should be in qiime split_libraries_fastq.py format
MAPFILE=${MAPFILE}\n";

print OUT "#the oligo file, to remove the primer from the sequence
OLIGO=${OLIGO}\n";

$QUAL="Q";
print OUT "#last_bar_qual_character used by split_libraries_fastq.py
#Q is a good guess if there is no mock to validate this
QUAL=$QUAL\n";


$BADRUN=0;

print OUT "#max_bad_run_length for split_libraries_fastq.py
BADRUN=$BADRUN\n";

#estimate length and bar length from fastq file and primer from oligo file

open (TEMP, "<${OLIGO}") or die "Can't open ${OLIGO}\n";
while ($line=<TEMP>){
    next if ($line=~/^\#/);
    ($name, $seq)=split ("\t", $line);
    (@bases)=split ("", $seq);
    $PRILEN=@bases;
}

close (TEMP);

$/="@";

open (TEMP, "<${SOLFILEF}") or die "Can't open ${SOLFILEF}\n";
while ($line=<TEMP>){
    chomp ($line);
    next unless ($line);
    ($header, $seq, $head2, $qual)=split ("\n", $line);
    $head2=();
    $qual=();
    (@bases)=split ("", $seq);
    $totlen=@bases;
    $diff=$totlen-$PRILEN;
    if ($diff>= 77){
	#the read is at least 77 bp or longer;
	$MINLEN=$PRILEN+77;
	$TRIM=77;
	print OUT "#MINLEN set automatically
MINLEN=${MINLEN}

#trimmed length
TRIM=77

#primer length
PRILEN=${PRILEN}

#set alignment for the right size for 77 bases trimmed
FALIGN=/data/spacocha/tmp/new_silva_short_unique_1_151.fa

#set clean parameters for FALIGN
ALIGNSTART=1
ALIGNEND=151\n";
	$FALIGN="/data/spacocha/tmp/new_silva_short_unique_1_151.fa";
	$ALIGNSTART=1;
	$ALIGNEND=151;

    }elsif ($diff == 76){
	$MINLEN=$totlen;
	$TRIM=76;
	print OUT "#MINLEN set to seq length
MINLEN=$MINLEN

#trimmed length
TRIM=$TRIM

#primerlength
PRILEN=$PRILEN

#set alignment for the right size for 77 bases trimmed
FALIGN=/data/spacocha/tmp/new_silva_short_unique_1_151.fa

#set clean parameters for FALIGN
ALIGNSTART=1
ALIGNEND=149\n";
        $FALIGN="/data/spacocha/tmp/new_silva_short_unique_1_149.fa";
	$ALIGNSTART=1;
	$ALIGNEND=149;

    } else {
	if ($diff < 76){
	    die "${programname} error: currently not able to assign a trim length or sequence alignment with this length and primer $totlen, $PRILEN . Diff $diff must be >=76\n";
	}
    }
    if ($header=~/\#(.+)\//){
	($barseq)=$header=~/\#(.+)\//;
	(@bases)=split ("", $barseq);
	$BARLEN=@bases;
	print OUT "#Barlength from information in header between\# and \/
BARLEN=${BARLEN}\n";

    } else {
	die "${programname} error: currently not able to find barlen from this header information\n";
    }
    last;
}

close (TEMP);


#latest eOTU program
$ERRORPROGRAM="find_seq_errors34.pl";
$EOTUFILE="/data/spacocha/bin/methods_scripts/eOTU_parallel.csh";
$PCLUST="/data/spacocha/bin/ProgressiveClustering5.csh";
$UPPER=98;
$LOWER=90;
$CUTOFF=1- ${LOWER}/100;
$QSUBNO=99;
print OUT "#Lastest distribution-based clustering algorithm
ERRORPROGRAM=${ERRORPROGRAM}

#Latest wrapper for the distirbtion-based clustering algorithm
EOTUFILE=${EOTUFILE}

#genetic cutoff for distribution-based clustering
CUTOFF=$CUTOFF

#Latest ProgressiveClustering algorithm
PCLUST=${PCLUST}

#Upper bounds of progressive clustering
UPPER=${UPPER}

#lower bounds of ProgressiveClustering
LOWER=${LOWER}

#QSUB NUM
QSUBNO=${QSUBNO}\n";


${RAWPROG}="/data/spacocha/bin/methods_scripts/RunQiime_rawdata.csh";
print OUT "#Program used to process rawdata
RAWPROG=${RAWPROG}\n";

${QIIMEFILE}="${UNIQUE}_output/seqs.trim.names.${TRIM}.fa";

print OUT "QIIMEFILE=${QIIMEFILE}\n";

close (OUT);

$/="\n";
##################
#Run Qiime Rawdata
##################

($sysoutput)= `qsub -cwd ${RAWPROG} ${vfile}`;
print "Job submitted: qsub -cwd ${RAWPROG} ${vfile}\n$sysoutput";
#file2 is the output number of the submission
(${prono}) =$sysoutput=~/Your job-*a*r*r*a*y* ([0-9]{6})/;
die "Missing prono $prono
$sysoutput\n" unless ($prono);

print "Checking for finished status of $prono\n";
finished_sub ($prono, 0);
print "${RAWPROG} is finished: $prono \n";

if (-e $QIIMEFILE){
    print "Raw data is finished
Start progressive clustering\n";
    
} else {
    die "$programname error: did not complete through raw data processing. ${QIIMEFILE} does not exist. 
Troubleshooting ideas
1.) Check values in $vfile and try to find obvious errors to fix
2.) Look in ${RAWPROG} and start to run these programs manually with values from $vfile
3.) Write spacocha\@mit.edu for help\n";
}

##############################
#Run the ProgressiveClustering
##############################

($sysoutput) = `qsub -cwd $PCLUST $vfile`;
print "Job submitted: qsub -cwd $PCLUST $vfile\n$sysoutput";
#file2 is the output number of the submission
(${prono}) =$sysoutput=~/Your job-*a*r*r*a*y* ([0-9]{6})/;
die "Missing prono $prono
$sysoutput\n" unless ($prono);

print "Checking for finished status of $prono\n";
finished_sub ($prono, 0);
print "$PCLUST is finished: $prono \n";

${PCLUSTOUTPUT}="${UNIQUE}.PC.final.list";
if (-e $PCLUSTOUTPUT){
    open (CHECK, "<${PCLUSTOUTPUT}") or die "Can't open ${PCLUSTOUTPUT}\n";
    for (<CHECK>){
	$processes=${.};
    }
    close (CHECK);
} else {
    die "$programname error: Did not finish ProgressiveClustering algorithm.
Troubleshooting ideas:                                                                                                                                                                               
1.) Check values in $vfile and try to find obvious errors to fix
2.) Look in ${PCLUST} and start to run these programs manually with values from $vfile
3.) Write spacocha\@mit.edu for help\n";
}

$sloop=1;
print "Beginning submission loop $sloop\n";
until ($sloop >$processes){    
    #figure out the range of numbers to submit
    $eloop = $sloop+$QSUBNO;
    if ($eloop >$processes){
	$difference= $processes - $sloop;
	$neweloop=$sloop + $difference;
	$eloop = $neweloop;
    }
    #submit the program
    $sysoutput = `qsub -cwd -t ${sloop}-${eloop} $EOTUFILE ${vfile}`;
    print "Submitted job:qsub -cwd -t ${sloop}-${eloop} $EOTUFILE ${vfile}\n$sysoutput\n";
    (${prono}) =$sysoutput=~/Your job-*a*r*r*a*y* ([0-9]{6})/;
    die "Missing prono:$prono\n" unless ($prono);
    #do a "soft finish" meaning, I will submit another round of jobs 
    #even when there are still 2 going from any of the preceeding processes
    print "Checking for soft finish of $prono\n";
    finished_sub ($prono, 2);
    push (@finisharray, $prono);
    print "$EOTUFILE is complete: sloop $sloop eloop $eloop\n";
    $sloop+=$QSUBNO;
    $sloop++;
}

print "Looking for hard finish of program\n";
#now do a hard finish to make sure they are all complete
foreach $process (@finisharray){
    finished_sub ($process, 0);
}

print "Evaluating results\n";

#####################################
# Evaluate the results of the wrapper
#####################################

system ("perl ${BIN}/evaluate_eOTU_results5.pl $vfile ${UNIQUE}_eval_output\n"); 

open (CHECK, "<${UNIQUE}_eval_output.log") or die "Can't open ${UNIQUE}_eval_output.log\n";
while ($checkline=<CHECK>){
    chomp ($checkline);
    next unless ($checkline);
    if ($checkline=~/All of the .+ of error files \(${UNIQUE}\*.f0.err\) were created/){
	$errorok="complete";
    } elsif ($checkline=~/All of the error files finished/){
	$errorfinished="complete";
    } elsif ($checkline=~/All of the .+ of log files \(${UNIQUE}\*.process.f0.log\) were created/){
	$logok="complete";
    } elsif ($checkline=~/There were [n][o] WARNINGs/){
	$warnings="no";
    }
}

if ($errorok && $errorfinished && $logok && $warnings){
    print "Parallel processing ran ok, continuing with processing\n";
} else {
    die "$programname error: The evaulation system either showed an error or failed.
Did not complete the error checking program for some reason:
error files created: $errorok
error files finished; ${errorfinished}
log files created: $logok
warnings were found: ${warnings}

This will need attention. Either re-run failures by resubmitting ${UNIQUE}_eval_output.resubmit.pl 
or address problems found in ${UNIQUE}_eval_output.log
\n";
}

##########################
#Clean up and characterize
##########################
$sysoutput = `qsub -cwd /data/spacocha/bin/methods_scripts/clean_up_parallel_ultra.csh ${vfile}`;
print "Submitted job:qsub -cwd /data/spacocha/bin/methods_scripts/clean_up_parallel_ultra.csh ${vfile}\n$sysoutput\n";
(${prono}) =$sysoutput=~/Your job-*a*r*r*a*y* ([0-9]{6})/;
die "Missing prono:$prono\n" unless ($prono);
print "Checking for finish of $prono\n";
finished_sub ($prono, 0);

$sysoutput = `qsub -cwd /data/spacocha/bin/methods_scripts/Classify_mat.csh ${vfile}`;
print "Submitted job:qsub -cwd /data/spacocha/bin/methods_scripts/Classify_mat.csh ${vfile}\n$sysoutput\n";
(${prono}) =$sysoutput=~/Your job-*a*r*r*a*y* ([0-9]{6})/;
die "Missing prono:$prono\n" unless ($prono);
print "Checking for finish of $prono\n";
finished_sub ($prono, 0);


print "Program complete\n";
#################
# Record end time
#################

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
$isdst="NA";
$wday="NA";
$yday="NA";
$newyear = $year+1900;
$newmonth=$mon+1;
$lt= "$newmonth-$mday-$newyear $hour:$min:$sec";

print "Time finished: $lt\n";



sub finished_sub {
    my ($prono, $limit) = (@_);
    $sleepsec=30;
    $finished=();
    until ($finished){
	#check if $prono is listed
	#print "Checking system for ${prono}\n";
	$qstatoutput =`qstat`;
	(@qlines)=split ("\n", $qstatoutput);
	$rprocesses=0;
	$qprocesses=0;
	foreach $qline (@qlines){
	    ($job, $prior, $name, $user, $stat)=split (" ", $qline);
	    $name=();
	    $prior=();
	    $user=();
	    $rprocesses++  if ($job=~/^[0-9]+/ && $job eq "$prono" && $stat eq "r");
	    $qprocesses++ if ($job=~/^[0-9]+/ && $job eq "$prono" && $stat eq "qw");
	}
	
	$finished++ if ($rprocesses <= $limit && $qprocesses == 0);
	sleep ($sleepsec);
    }
    return ($finished);
}

sub dieHelp {
die "This perl script was created to estimate parameters and run scripts to process                                                                                                         
fastq data into eOTUs using distribution-based clustering.                                                                                                                                          
                                                                                                                                                                                                    
Usage: perl $programname -f fastq -o oligo -m mapping -u unique\n";
}
