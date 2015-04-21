#! /usr/bin/perl -w

die "Use this program to evaulate the find_seq_errors.pl 
Be in a folder where all of the files

Usage: vars_files > redirect_results\n" unless (@ARGV);
($vars)=(@ARGV);
chomp ($vars);
open (IN, "<$vars" ) or die "Can't open $vars\n";
while ($line=<IN>){
    chomp ($line);
    #get the PCLUSTOUTPUT name so you can check to see how many there are supposed to be
    if ($line=~/PCLUSTOUTPUT=/){
	($PCLUSTOUTPUT)=$line=~/PCLUSTOUTPUT=(.+)$/;
	print "PCLUSTOUTPUT $PCLUSTOUTPUT\n";
    }
    if ($line=~/QUAL=/){
	($QUAL)=$line=~/QUAL=(.+)$/;
	print "QUAL $QUAL\n";
    }
    if ($line=~/FNUMBER=/){
	($FNUMBER)=$line=~/FNUMBER=(.+)$/;
	print "FNUMBER $FNUMBER\n";
    }
}

close (IN);

$UNIQUE="${QUAL}/eOTU_parallel/parallel";
#look for the number of lines in the PCLUSTOUTPUT

if ("-e $PCLUSTOUTPUT"){
    $totlines=`cat $PCLUSTOUTPUT | wc -l`;
    chomp ($totlines);
    print "Looking for $totlines of each file type\n";
} else {
    die "EVAL WARNING: Did not generate the PCLUSTOUTPUT $PCLUSTOUTPUT
EVAL ACTION: Start from the ProgressiveClustering program to generate this file\n";
}
#Looking for the error files
if ("-e ${UNIQUE}*.f${FNUMBER}.err"){
    @errfiles = `ls ${UNIQUE}*.f${FNUMBER}.err`;
    chomp (@errfiles);
    $numbererrs = @errfiles;
    chomp ($numbererrs);
    if ($numbererrs == $totlines){
        print "All of the $totlines of error files (${UNIQUE}*.f${FNUMBER}.err) were created\n";
    } else {
        print "EVAL WARNING: Missing some error files: $numbererrs out of $totlines were created
EVAL ACTION: Rerun eOTU_core3.csh with the following lines:\n";
	$filetype = "error files";
	($result) = printmissingno ($totlines, $filetype);
    }
    print "Evaluating how many of the $numbererrs are finished\n";
    foreach $f (@errfiles){
	chomp ($f);
	$finished= `cat $f | grep "Finished"`;
	chomp ($finished);
	$unfin=0;
	unless ($finished){
	    print "EVAL WARNING:${f} did not finish\n";
	    $unfin++;
	}
    }
    print "All of the error files finished\n" unless ($unfin);
} else {
    print "EVAL WARNING: ${UNIQUE}*.f${FNUMBER}.err files do not exist
EVAL ACTION: Rerun eOTU_core program\n";
}

#look too see whether files were generated
if ("-e ${UNIQUE}*.log"){
    @logfiles = `ls ${UNIQUE}*.log`;
    $numberlogs = @logfiles;
    if ($numberlogs == $totlines){
	print "All of the $totlines of log files (${UNIQUE}*.log) were created\n";
    } else {
	print "EVAL WARNING: Missing some log files: $numberlogs out of $totlines were created
EVAL ACTION: Rerun eOTU_core3.csh with the following lines\n";
	$filetype="log";
	($result) = printmissingno (@logfiles, $totlines, $filetype);
    }
    $warning=();
    foreach $file (@logfiles){
	$result=`cat ${file}`;
	if ($result=~/WARN/){
	    print "There was at least one  WARNING in $file, check to see what the warning is\n";
	    $warning++;
	}
    }
    print "There were no WARNINGs\n" unless ($warning);
} else {
    print "EVAL WARNING: ${UNIQUE}*.log files do not exist
EVAL ACTION: Rerun the eOTU_core program\n";
    
}

sub printmissingno {

    my ($total, $filetype)= @_;
    my ($f);
    my ($i);
    my (%gothash);
    my ($done);
    %gothash=();
    $done=0;
    if ($filetype eq "error files"){
	foreach $f (@errfiles){
	    chomp ($f);
	    next unless ($f=~/${UNIQUE}.*.process/);
	    ($process)=${f}=~/${UNIQUE}.([0-9]+).process/;
	    die "F: $f Process: $process\n" unless ($process);
	    $gothash{$process}++;
	}
	$i=1;
	if ($total){
	    until ($i >$total){
		print "$i\t$filetype\n" unless ($gothash{$i});
		$i++;
	    }
	    $done++;
	    return ($done);
	} else {
	    die "Missing total $total\n";
	}
    }
}
