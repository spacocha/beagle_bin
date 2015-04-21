#! /usr/bin/perl -w

die "Use this program to make random erros in sequence data
This will use the geometric distribution
error_prob- this is the probability used to determine whether a sequence will have an error (0.85 seems ok)
seq_prob- This is the probability used to determine where the error is from the 3' end (0.5 is ok)
For prob use 0.9 for mostly 0's and 0.5 will give about half 0's
Usage:  tab lineno output\n" unless (@ARGV);
($tab, $lineno) = (@ARGV);
die "Missing output\n" unless ($lineno);
chomp ($tab);
chomp ($lineno);
$readprob=0.80;
$seqlen=76;

open (LOG, ">${output}.log") or die "Can't open ${output}.log\n";
open (FA, ">${output}.fa") or die "Can't open ${output}.fa\n";
$curline=0;
open (IN, "<${tab}") or die "Can't open ${tab}\n";
while ($line1 = <IN>){
    chomp ($line1);
    $curline++;
    next unless ($curline == $lineno);
    ($name, $count, $startcount, $lib, $sequence) = split ("\t", $line1);
    $output="$name"."_"."$lib";
    open (LOG, ">${output}.log") or die "Can't open ${output}.log\n";
    open (FA, ">${output}.fa") or die "Can't open ${output}.fa\n";
    print LOG "Working on:\t$name\t$count\t$sequence\n";
}
close (IN);

print LOG "$sequence\n" if ($verbose);
die "Missing seq $sequence $name\n" unless ($sequence);
system ("rm ${output}.Rfile.tab") if (-e "${output}.Rfile.tab");
open (RUN1, ">${output}.Rfile.tab") or die "Can't open ${output}.Rfile.tab\n";
print RUN1 "test2 <- rgeom($count, $readprob)                                                                 
write.table(test2,file=\"${output}.Rfile.res\",quote=FALSE, sep=\"\t\")";
close (RUN1);

system ("R --slave --vanilla --silent < ${output}.Rfile.tab >> ${output}.Rfile.tab");
open (RES1, "<${output}.Rfile.res") or die "Can't open ${output}.Rfile.res\n";
$first=1;
while ($Rline=<RES1>){
    chomp ($Rline);
    if ($first){
	$first=0;
	next;
    } else {
	(@pieces)=split ("\t", $Rline);
	($seqno)=$pieces[0];
	($toterr)=$pieces[1];
	#create fasta entry after getting the number of errors
	$i=0;
	if ($toterr){
	    %tempposhash=();
	    (@workingbases)=split ("", $sequence);
	    $changelog=();
	    $n=$seqlen-1;
	    until ($i>=$toterr){
		if ($n<1){
		    print LOG "Gone through without getting it; start over\n" if ($verbose);
		    $n=$seqlen-1;
		    (@workingbases)=split ("", $sequence);
		    %tempposhash=();
		    $changelog=();
		    $attempt++;
		    if ($attempt>4){
			die "Couldn't get enough errors $toterr $attempt\n";
		    }
		}
		print LOG "I'm looking for an error\n" if ($verbose);
		#generate random error near end of sequence
		system ("rm ${output}.Rfile.seq") if (-e "${output}.Rfile.seq");
		system ("rm ${output}.Rfile.seq.res") if (-e "${output}.Rfile.seq.res");
		#make the error rate fall off with length
		$m=100-$n;
		#high n means 0 is more likely
		#start with 50:50 chance at the end of the sequence
		open (RUN2, ">${output}.Rfile.seq") or die "Can't open ${output}.Rfile.seq\n";
		print RUN2 "test2 <- rhyper(1, $m, $n, 1)
write.table(test2,file=\"${output}.Rfile.seq.res\",quote=FALSE, sep=\"\t\")\n";
		close (RUN2);
		
		system ("R --slave --vanilla --silent < ${output}.Rfile.seq >> ${output}.Rfile.seq");
		open (RES2, "<${output}.Rfile.seq.res") or die "Can't open ${output}.Rfile.seq.res\n";
		$first2=1;
		while ($Rline=<RES2>){
		    chomp ($Rline);
		    (@pieces)=split ("\t", $Rline);
		    if ($first2){
			$first2=0;
		    } else {
			($na)=$pieces[0];
			($error)=$pieces[1];
			print LOG "Is it an error? $error\n" if ($verbose);
		    }
		}
		close (RES2);
		if ($error){
		    print LOG "Error ($error) so change base $n\n" if ($verbose);
		    #change this base
		    #what is the base now
		    ($base)=$workingbases[$n];
		    die "It doesn't exist $base $n\n" unless ($base);
		    print LOG "Changing base $base\n" if ($verbose);
		    $dija=();
		    until ($dija){
			($newbase)= change_base ();
			print LOG "Did it work? $newbase\n" if ($verbose);
			if ($newbase eq $base){
			    #try again
			    $dija=();
			    print LOG "No\n" if ($verbose);
			} else {
			    $workingbases[$n]=$newbase;
			    $dija++;
			    print LOG "Yes\n" if ($verbose);
			}
		    }
		    if ($changelog){
			$changelog="$changelog"."$n"."$base"."$newbase";
		    } else {
			$changelog="$n"."$base"."$newbase";
		    }
		    print LOG "Base changed, Adding 1 to i $i\n" if ($verbose);
		    $tempposhash{$n}++;
		    $i++;
		    $n--;
		} else {
		    print LOG "Not an error, going for the next base\n" if ($verbose);
		    #check out the next base
		    $n--;
		}
	    }
	    $newseq=();
	    print LOG "$m $n\n" if ($verbose);
	    foreach $b (@workingbases){
		if ($newseq){
		    $newseq="$newseq"."$b";
		} else {
		    $newseq="$b";
		}
	    }
	    $newname="$name"."_"."$toterr"."_"."$changelog";
	    foreach $pos (keys %tempposhash){
		print LOG "Going through positions to transfer from tempposhash to poshash: $pos $tempposhash{$pos}\n" if ($verbose);
		($poshash{$pos})+=$tempposhash{$pos};
	    }
	} else {
	    $newseq=$sequence;
	    $newname="$name"."_correct";
	}
	$errorrate{$toterr}++;
	print FA ">${lib}_${startcount} $newname\n$newseq\n";
	$startcount++;
    }
}
close (RES1);

print LOG "Total Errors per seq\tTotal num of seqs with those errors\n";
foreach $err (sort keys %errorrate){
    print LOG "$err\t$errorrate{$err}\n";
}

print LOG "Position\tTotal Errors at that position\n";
foreach $pos (sort keys %poshash){
    print LOG "$pos\t$poshash{$pos}\n";
}


sub change_base{
    my ($newbase);
    my($got);
    my(%hash);
    my($random);
    my($four);
    $four=4;
    @randbase= ("A", "T", "C", "G");
    $got=0;
    until ($got){
	$random=int(rand($four));
	print "base $base\n" if ($verbose);
	die "Not a thing base $base\n" unless ($base);
	die "Not a thing randbase[random] $randbase[$random]\n" unless ($randbase[$random]);
	$got++ unless ($randbase[$random] eq $base);
    }
    return ($randbase[$random]);
	
}
