
#! /usr/bin/perl
#
#

	die "Usage: <Solexa File1> <UC file> <output_prefix>\n" unless (@ARGV);
	($file1, $barfile, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($barfile);
chomp ($output);

open (IN1, "<$barfile") or die "Can't open $barfile\n";
while ($line=<IN1>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/^\#/);
    ($type, $seed, $len, $one, $two, $three, $four, $five, $name, $seedname)=split (" ", $line);
    if ($type eq "S"){
	$uchash{$name}="A".${seed};
	open ($uchash{$name}, ">${output}.${seed}") or die "Can't open ${output}.${seed}\n";
    } elsif ($type ne "C"){
	$uchash{$name}="A".${seed};
    }
}
close (IN);

$/="@";

open (IN2, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN2>){
		chomp ($line);
		next unless ($line);
		($header, $sequence, $useless1, $useless2)=split("\n", $line);
		#only keep sequences that have the exact bar code right at the beginning of 3rd read
		($name) = $header=~/^(.+\#.*.{7})\//;
		next unless ($uchash{$name});
		$BAR = $uchash{$name};
		print $BAR "\@${line}";
	    }
	close (IN2);

foreach $name (keys %uchash){
    close ($uchash{$name});
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
