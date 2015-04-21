#! /usr/bin/perl
#
#

	die "Usage: <fasta> <V> <J> > redirect\n" unless (@ARGV);
	($file1, $Vfile, $Jfile) = (@ARGV);

	die "Please follow command line args\n" unless ($Jfile);
chomp ($file1);
chomp ($Vfile);
chomp ($Jfile);

$/=">";
open (IN1, "<$Vfile") or die "Can't open $Vfile\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($parent, @seqs)=split("\n", $line1);
    ($rc_seq)=join ("", @seqs);
    ($sequence)=revcomp();
    $Vhash{$parent}=$sequence;
    
}
close (IN1);

open (IN1, "<$Jfile") or die "Can't open $Jfile\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($parent, @seqs)=split("\n", $line1);
    ($sequence)=join ("", @seqs);
    $Jhash{$parent}=$sequence;
}
close (IN1);
open (IN1, "<$file1") or die "Can't open $file1\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($parent, @seqs)=split("\n", $line1);
    ($sequence)=join ("", @seqs);
    foreach $Jname (sort keys %Jhash){
	#does the sequence have a recognizable J primer
	if ($sequence=~/$Jhash{$Jname}/){
 	    ($first, $match, $end)=$sequence=~/^(.*)($Jhash{$Jname})(.*)$/;
	  #  die "This has the primer $first $match $end\n";
	    if ($totalJ{$parent}){
		die "Some hit twice $parent $Jname $totalJ{$parent}\n";
	    } else {
		$totalJ{$parent}=$Jname;
		$totalJcount++;
	    }
	    #does the sequence have a V primer in the end of the J region
	    foreach $Vname (sort keys %Vhash){
		if ($end=~/$Vhash{$Vname}/){
		    ($first2, $match2, $end2)=$end=~/^(.*)($Vhash{$Vname})(.*)$/;
		    if ($totalV{$parent}){
			($first2, $match2, $end2)=$end=~/^(.*)($Vhash{$totalV{$parent}})(.*)$/;
			(@bases)=split ("", $first2);
			$newlen=@bases;
			if ($newlen <=$totalVlen{$parent}){
			    $hash{$parent}=$first2;
			    $totalV{$parent}=$Vname;
			    $totalVlen{$parent}=$newlen;
			}
		    } else {
			(@bases)=split ("", $first2);
			$length=@bases;
			$totalV{$parent}=${Vname};
			$totalVlen{$parent}=$length;
			$hash{$parent}=$first2;
		    }
		}
	    }
	}
    }


}
close (IN1);

foreach $parent (sort keys %hash){
    print ">$parent Jprimer $totalJ{$parent} Vprimer $totalV{$parent}\n$hash{$parent}\n";
}

############
#subroutines of very common use
############


sub revcomp{
    (@pieces) = split ("", $rc_seq);
    #make reverse complement
    $j = @pieces;
    $j-=1;
    $seq = ();
    until ($j < 0){
	if ($pieces[$j]){
	    if ($pieces[$j] eq "A"){
		$seq = "$seq"."T";
	    } elsif ($pieces[$j] eq "T"){
		$seq = "$seq"."A";
	    } elsif ($pieces[$j] eq "C"){
		$seq = "$seq"."G";
	    } elsif ($pieces[$j] eq "G"){
		$seq = "$seq"."C";
	    } elsif ($pieces[$j] eq "N"){
		$seq = "$seq"."N";
	    } else {
		die "$pieces[$j]\n";
	    }
	} else {
	    die "NO j $j\n";
	}
	$j--;
    }
    return ($seq);
}


