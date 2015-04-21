#! /usr/bin/perl -w
#
#

	die "Usage: variable_file\n" unless (@ARGV);
	($vfile) = (@ARGV);

	die "Please follow command line args\n" unless ($vfile);
chomp ($vfile);

print "Reading in variables\n";
open (IN, "<${vfile}") or die "Can't open $vfile\n";
while ($line=<IN>){
    chomp ($line);
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


if ("-e $PCLUSTOUTPUT"){
    open (CHECK, "<${PCLUSTOUTPUT}") or die "Can't open ${PCLUSTOUTPUT}\n";
    for (<CHECK>){
	$processes=${.};
    }
    close (CHECK);
}

$i=1;
until ($i >$processes){    
    $logfile="${UNIQUE}.${i}.process.f${FNUMBER}.err.log";
    if ("-e $logfile"){
	open (LOG, "<${logfile}") or die "Can't open $logfile\n";
	while ($line=<LOG>){
	    chomp ($line);
	    next unless ($line);
	    next unless ($line=~/Time started/ || $line=~/Finished distribution based clustering:/);
	    if ($line=~/Time started/){
		(@startpieces)=split (" ", $line);
		($starttime)=pop (@startpieces);
		($startdate)=pop (@startpieces);
		$starttimehash{$i}{$startdate}{$starttime}++;
	    } else {
		#must be the end
		(@endpieces)=split (" ", $line);
                ($endtime)=pop (@endpieces);
                ($enddate)=pop (@endpieces);
		$endtimehash{$i}{$enddate}{$endtime}++;
	    }
	}
	close (LOG);
    }
    $errfile="${UNIQUE}.${i}.process.f${FNUMBER}.err.err";
    if (%{$endtimehash{$i}}){
	if ("-e $errfile"){
	    open (ERR, "<${errfile}") or die "Can't open $errfile\n";
	    while ($line=<ERR>){
		chomp ($line);
		next unless ($line);
		if ($line=~/Changefrom/ || $line=~/parent/){
		    $total{$i}++;
		}
	    }
	    close (ERR);
	}
    }
    $i++;
}

foreach $i (sort keys %starttimehash){
    foreach $time (sort keys %{$starttimehash{$i}}){
	foreach $date (sort keys %{$starttimehash{$i}{$time}}){
	    if (%{$endtimehash{$i}} && $total{$i}){
		foreach $endtime (sort keys %{$endtimehash{$i}}){
		    foreach $enddate (sort keys %{$endtimehash{$i}{$endtime}}){
			print "$i\t$time\t$date\t$endtime\t$enddate\t$total{$i}\n";
		    }
		}
	    }
	}
    }
}
