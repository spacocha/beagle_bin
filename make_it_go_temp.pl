#! /usr/bin/perl -w
#
#

	die "Usage: program output\n" unless (@ARGV);
	($file, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file);
chomp ($output);

#loop through these with sets of 100
$sloop=1;
#how many do I need to loop through?
$eloop=30;

until ($sloop >$eloop){
    system ("qsub -cwd RSP_d.csh3 $sloop > ${output}");
#file2 is the output number of the submission                                                                                                                                                                   
    open (IN, "<${output}") or die "Can't open $output\n";
    while ($line=<IN>){
	chomp ($line);
	(${prono}) =$line=~/Your job-*a*r*r*a*y* ([0-9]{6})/;
	die "Missing prono $prono\n" unless ($prono);
    }
    close (IN);
    
    finished_sub ($prono);
    print "RSP_d.csh2 is finished: $prono $sloop\n";
    $sloop++;
}

system ("ls ./ML_test/*.lin > ./matfiles_list");

system ("perl ~/bin/merge_mats.pl ./matfiles_list > ./merged_mats\n");

print "Your file merged_mats is ready\n";


sub finished_sub {
    $sleepsec=30;
    $finished=();
    until ($finished){
	#check if $prono is listed
	$running=();
	print "Checking system for ${prono}\n";
	system ("qstat | grep \"$prono\" > ${output}2\n");
	open (CHECK, "<${output}2") or die "Can't open ${output}2\n";
	while ($line=<CHECK>){
	    chomp ($line);
	    ($running) = $line=~/${prono}/;
	}
	close (CHECK);
	$finished++ unless ($running);
	sleep ($sleepsec);
    }
    return ($finished);
}
