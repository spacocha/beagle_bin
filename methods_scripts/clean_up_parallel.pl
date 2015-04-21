#! /usr/bin/perl -w
#
#

	die "Usage: variable_file\n" unless (@ARGV);
	($vfile) = (@ARGV);

	die "Please follow command line args\n" unless ($vfile);
chomp ($vfile);

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
$isdst="NA";
$wday="NA";
$yday="NA";
$newyear = $year+1900;
$newmonth=$mon+1;
$lt= "$newmonth-$mday-$newyear $hour:$min:$sec";

print "Time started: $lt\n";

print "Reading in variables\n";
open (IN, "<${vfile}") or die "Can't open $vfile\n";
while ($line=<IN>){
    chomp ($line);
    if ($line=~/EOTUFILE=/){
	($eOTUfile)=$line=~/EOTUFILE=(.+)$/;
	print "eOTUfile $eOTUfile\n";
    }
    if ($line=~/PCLUST=/){
	($clusterprogram)=$line=~/PCLUST=(.+)$/;
	print "clusterprogram $clusterprogram\n";
    }
    if ($line=~/BIN=/){
        ($BIN)=$line=~/BIN=(.+)$/;
	print "BIN $BIN\n";
    }
    if ($line=~/UNIQUE=/){
        ($UNIQUE)=$line=~/UNIQUE=(.+)$/;
        print "UNIQUE $UNIQUE\n";
    }
    if ($line=~/PCLUSTOUTPUT=/){
	($PCLUSTOUTPUT)=$line=~/PCLUSTOUTPUT=(.+)$/;
	print "PCLUSTOUTPUT $PCLUSTOUTPUT\n";
    }
    if ($line=~/QSUBNO=/){
	($QSUBNO)=$line=~/QSUBNO=(.+)$/;
	print "QSUBNO $QSUBNO\n";
    }
}


system ("cat ${UNIQUE}.*.process.f0.err > ${UNIQUE}.all_err.txt\n");
system ("perl ${BIN}/err2list3.pl ${UNIQUE}.all_err.txt > ${UNIQUE}.all_err.list\n");
system ("perl ${BIN}/list2mat.pl ${UNIQUE}.f0.mat ${UNIQUE}.all_err.list eco > ${UNIQUE}.all_err.list.mat\n");
system ("perl ${BIN}/fasta2filter_from_mat.pl  ${UNIQUE}.all_err.list.mat ${UNIQUE}.fa > ${UNIQUE}.all_err.list.mat.fa\n");
system ("perl ${BIN}/evaluate_eOTU_results5.pl $1 ${UNIQUE}_eval_output\n"); 

#Run a finisher script which contains the following PLUS A UCHIME CHIMERA CHECKER! FINISH THIS

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
