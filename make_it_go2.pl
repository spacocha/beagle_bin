#! /usr/bin/perl -w
#
#

	die "Usage: variable_file\n" unless (@ARGV);
	($vfile) = (@ARGV);

	die "Please follow command line args\n" unless ($vfile);
chomp ($vfile);

open (IN, "<${vfile}") or die "Can't open $vfile\n";
while ($line=<IN>){
    chomp ($line);
    if ($line=~/EOTUFILE=/){
	($eOTUfile)=$line=~/EOTUFILE=(.+)$/;
    }
    if ($line=~/PCLUST=/){
	($clusterprogram)=$line=~/PCLUST=(.+)$/;
    }
    if ($line=~/PCLUSTOUTPUT=/){
	($PCLUSTOUTPUT)=$line=~/PCLUSTOUTPUT=(.+)$/;
    }
    if ($line=~/QSUBNO=/){
	($QSUBNO)=$line=~/QSUBNO=(.+)$/;
    }
}

($sysoutput) = `qsub -cwd $clusterprogram $vfile`;
#file2 is the output number of the submission
(${prono}) =$sysoutput=~/Your job-*a*r*r*a*y* ([0-9]{6})/;
die "Missing prono $prono
$sysoutput\n" unless ($prono);

finished_sub ($prono, 0);
print "$clusterprogram is finished: $prono \n";

if ("-e $PCLUSTOUTPUT"){
    open (CHECK, "<${PCLUSTOUTPUT}") or die "Can't open ${PCLUSTOUTPUT}\n";
    for (<CHECK>){
	$processes=${.};
    }
    close (CHECK);
}

$sloop=1;

until ($sloop >$processes){    
    #figure out the range of numbers to submit
    $eloop = $sloop+$QSUBNO;
    if ($eloop >$processes){
	$difference= $processes - $sloop;
	$neweloop=$sloop + $difference;
	$eloop = $neweloop;
    }
    #submit the program
    $sysoutput = `qsub -cwd -t ${sloop}-${eloop} $eOTUfile ${vfile}`;
    (${prono}) =$sysoutput=~/Your job-*a*r*r*a*y* ([0-9]{6})/;
    die "Missing prono:$prono\n" unless ($prono);
    finished_sub ($prono, 2);
    print "$eOTUfile is complete: sloop $sloop eloop $eloop\n";
    $sloop+=$QSUBNO;
    $sloop++;
}


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
