#! /usr/bin/perl -w
#
#

	die "Usage: list_of_freclu_output_files list_of_UC_files list_of_UC_input_files> Redirect\n" unless (@ARGV);
	($flist, $ulist, $ilist) = (@ARGV);

	die "Please follow command line args\n" unless ($ilist);
chomp ($flist);
chomp ($ulist);
chomp ($ilist);

open (IN, "<$flist") or die "Can't open $flist\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name)=split ("\t", $line);
		($bar) = $name =~/^(.{7})/;
		open (IN2, "<$name") or die "Can't open $name\n";
		while ($line2=<IN2>){
		    chomp ($line2);
		    next unless ($line2);
		    ($parent, $one, $freq, $three, $four) = split ("\t", $line2);
		    next unless ($parent=~/^[ATGC]+$/);
		    $freqhash{$bar}{$parent}=$freq;
		    $totalhash{$bar}+=$freq;
		}
		close (IN2);
       	}
close (IN);

open (IN, "<$ilist") or die "Can't open $ilist\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name)=split ("\t", $line);
    ($bar) = $name =~/^(.{7})/;
    $/ = ">";
    open (IN2, "<$name") or die "Can't open $name\n";
    while ($line2=<IN2>){
        chomp ($line2);
        next unless ($line2);
	($fasta, @seqs) = split ("\n", $line2);
	$seq = join ("", @seqs);
	$seqhash{$bar}{$fasta}=$seq;
    }
    close (IN2);
    $/ = "\n";


}
close (IN);
$/="\n";

open (IN, "<$ulist") or die "Can't open $ulist\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name)=split ("\t", $line);
    ($bar) = $name=~/^(.{7})/;
    open (IN2, "<$name") or die "Can't open $name\n";
    while ($line2=<IN2>){
	chomp ($line2);
	next unless ($line2);
	($type, $seed, $len, $one, $two, $three, $four, $five, $name, $seedname)=split (" ", $line2);
	next if ($type =~/\#/);
	if ($type eq "S"){
	    $seedname = $name;
	    $uchash{$bar}{$seedname}{$name}++;
	} elsif ($type ne "C"){
	    $uchash{$bar}{$seedname}{$name}++;
	}
    }
    close (IN2);
}
close (IN);


#I have freqhash, seqhash and uchash
#I need to check what the distribution is across all bars
#for each member of a ucgroup

foreach $bar (keys %uchash){
    foreach $seed (keys %{$uchash{$bar}}){
	$start = 1;
	foreach $name (keys %{$uchash{$bar}{$seed}}){
	    #what is the distribution of each member in different bars?
	    ($sequence) = $seqhash{$bar}{$name};
	    next unless ($sequence);
	    #how many in this bar
	    ($thisfreq) = $freqhash{$bar}{$sequence};
	    @dist = ();
	    @bars = ();
	    $sum = ();
	    push (@dist, $thisfreq);
	    push (@bars, $bar);
	    $sum=+$thisfreq;
	    foreach $otherbar (sort keys %freqhash){
		next if ($otherbar eq $bar);
		if ($freqhash{$otherbar}{$sequence}){
		    push (@dist, $freqhash{$otherbar}{$sequence});
		    push (@bars, $otherbar);
		    $sum=+$freqhash{$otherbar}{$sequence};
		} else {
		    $NA = 0;
		    push (@dist, $NA);
		    push (@bars, $otherbar);
		}
	    }
	    next unless ($sum > 100);
	    print "Sequence";
	    foreach $barname (@bars){
		print "\t$barname";
	    }
	    print "\n";
	    print "$sequence";
	    foreach $thing (@dist){
		print "\t$thing";
	    }
	    print "\n";
	}
    }
    die if ($start == 1);
}
