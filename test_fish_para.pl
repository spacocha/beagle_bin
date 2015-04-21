#! /usr/bin/perl -w
#   Edited on 08/16/12 
#

$Rfile="Rfile";
$countmin=0;
$countmax=1000;
$libnomin=1;
$libnomax=30;
$count=$countmin;
#make a matrix with increasing number of counts and libraries
until ($count >=$countmax){
    $count++;
    $lib=$libnomin;
    until ($lib >=$libnomax){
	$lib++;
	#make a matrix with $count counts in each field of $lib libs
	$string=();
	$i=1;
	until ($i > $lib){
	    if ($string){
		$string="$string"."$count\t$count\n";
	    } else {
		$string="$count\t$count\n";
	    }
	    $i++;
	}
	#run chisq and fishers
	system ("rm ${Rfile}.fisp\n") if (-e "${Rfile}.fisp");
	open (INPUT, ">${Rfile}.in") or die "Can't open ${Rfile}.in\n";
	print INPUT "$string\n";
	close (INPUT);
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
	$isdst="NA";
	$wday="NA";
	$yday="NA";
	$newyear = $year+1900;
	$newmonth=$mon+1;
	if ($sec < 10){
	    $sec2="0"."$sec";
	} else {
	    $sec2=$sec;
	}
	$lt= "$newmonth-$mday-$newyear $hour:$min:$sec2";
	$starttime=$lt;
	system ("R --slave --vanilla --silent < ${Rfile}.fis >> ${Rfile}.err");		    
        ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
        $isdst="NA";
        $wday="NA";
        $yday="NA";
        $newyear = $year+1900;
        $newmonth=$mon+1;
	if ($sec < 10){
            $sec2="0"."$sec";
        } else {
            $sec2=$sec;
	}
        $lt= "$newmonth-$mday-$newyear $hour:$min:$sec2";
        $endtime=$lt;

	if (-e "${Rfile}.fisp"){
	    print "Good\t$lib\t$count\t$starttime\t$endtime\n";
	} else {
	    print "Bad\t$lib\t$count\t$starttime\t$endtime\n";
	}
    }
}

sub makeRexecutables {
    open (FIS, ">${Rfile}.fis") or die "Can't open ${Rfile}.fis\n";
    print FIS "x <- read.table(\"${Rfile}.in\", header = FALSE)
htest1<-fisher.test(x)
fisp <-htest1\$p.value
write.table(fisp,file=\"${Rfile}.fisp\",sep=\"\t\",row.names=FALSE,col.names=FALSE)\n";
    close (FIS);
}

