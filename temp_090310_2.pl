#! /usr/bin/perl
#
#

	die "Usage: <list of Solexa files to trim>\n" unless (@ARGV);
	($list) = (@ARGV);

	die "Please follow command line args\n" unless ($list);
chomp ($list);


open (IN1, "<$list") or die "Can't open $list\n";
while ($line=<IN1>){
    chomp ($line);
    next unless ($line);
    ($file1)=$line;
    $/=">";
    $count=1;
    $lnum=1;
#open the forward file and save for later
    
    open (IN2, "<$file1") or die "Can't open $file1\n";
    $got=0;
    until ($got){
	$line2=<IN2>;
	chomp ($line2);
	next unless ($line2);
	($header, @seqs)=split("\n", $line2);
	($sequence)=join ("", @seqs);
	$length = split ("", $sequence);
	$hash{$file1}=$length;
	$got++;
    }
    close (IN2);
    $/="\n";
}
close (IN1);
foreach $file (sort {$hash{$a} <=> $hash{$b}} keys %hash){
    $shortlen = $hash{$file};
    last;
}

$/=">";
foreach $file (keys %hash){
    open (IN, "<${file}") or die "Can't open ${file}\n";
    open (OUT, ">${file}.2") or die "Can't open ${file}.2\n";
    while ($line3=<IN>){
	chomp ($line3);
	next unless ($line3);
	($header, @seqs)=split("\n", $line3);
	($sequence)=join ("", @seqs);
	($shrtseq)=$sequence=~/^(.{$shortlen})/;
	print OUT ">$header\n$shrtseq\n\n";
    }
    close (IN);
    close (OUT);
}


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
