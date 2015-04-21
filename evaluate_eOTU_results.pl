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
    if ($line=~/UNIQUE=/){
	($UNIQUE)=$line=~/UNIQUE=(.+)$/;
	print "UNIQUE $UNIQUE\n";
    }
    if ($line=~/FNUMBER=/){
	($FNUMBER)=$line=~/FNUMBER=(.+)$/;
	print "FNUMBER $FNUMBER\n";
    }
}

close (IN);

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
	($result) = printmissingno (@errfiles, $totlines, $filetype);
    }
    print "Evaluating how many of the $numbererrs are finished\n";
    foreach $f (@errfiles){
	chomp ($f);
	$finished= `cat $f | grep "Finished"`;
	chomp ($finished);
	unless ($finished){
	    print "EVAL WARNING:${f} did not finish\n";
	}
    }
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
} else {
    print "EVAL WARNING: ${UNIQUE}*.log files do not exist
EVAL ACTION: Rerun the eOTU_core program\n";

}

sub printmissingno {

    my (@array, $total, $filetype)= @_;
    my ($f);
    my ($i);
    my (%gothash);
    my ($done);
    %gothash=();
    $done=0;
    foreach $f (@array){
	chomp ($f);
	($process)=${f}=~/${UNIQUE}.(.[0-9]+).process/;
	$gothash{$process}++;
    }
    $i=1;
    until ($i >$total){
	print "$i\t$filetype\n" unless ($gothash{$process});
	$i++;
    }
    $done++;
    return ($done);
}
