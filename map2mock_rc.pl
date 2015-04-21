#! /usr/bin/perl -w
#
#

	die "Usage: mock fasta > redirect\n" unless (@ARGV);
	($file1, $file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
chomp ($file2);

$/=">";
open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs)=split ("\n", $line);
    ($seq)=join ("", @seqs);
    $hash{$info}{"f"}=$seq;
    $rc_seq=$seq;
    ($newseq)=revcomp();
    $hash{$info}{"rc"}=$newseq;
}

close (IN);
	open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($OTU, @seqs)=split ("\n", $line);
		($seq)=join ("", @seqs);
		($seq2)=$seq;
		$seq=~s/-//g;
		foreach $mock (keys %hash){
		    foreach $orient (sort keys %{$hash{$mock}}){
			if ($hash{$mock}{$orient}=~/$seq/){
			    print "$OTU\t$mock\t$orient\t$seq\t$hash{$mock}{$orient}\n";
			}
		    }
		}
		
	}
	close (IN);
	
#! /usr/bin/perl
#
#

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

1;
