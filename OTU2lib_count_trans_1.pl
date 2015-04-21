#! /usr/bin/perl -w
#
#

	die "Use this program to take the tab file and make a matrix with the library counts
Usage: trans1 bar rc_yes_no> Redirect\n" unless (@ARGV);
	($file1,  $bar, $rcyn) = (@ARGV);
	die "Please follow command line args\n" unless ($bar);
chomp ($file1);
chomp ($bar);
chomp ($rcyn);

open (IN, "<${bar}") or die "Can't open ${bar}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/^\#/);
    #remove if it was removed at any step of the process
    ($lib, $bar) = split ("\t", $line);
    #($libshort)=$lib=~/^(.+)\.[0-9][0-9]$/;
    if ($rcyn=~/[yY]/){
	$rc_seq=$bar;
	($bar_rc)=revcomp();
	$bar=$bar_rc;
    }
    #$barhash{$bar}=$libshort;
    $barhash{$bar}=$lib;
    #$alllib{$libshort}++;
    $alllib{$lib}++;
}
close(IN);

open (IN, "<${file1}") or die "Can't open ${file1}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    #remove if it was removed at any step of the process
    next if ($line=~/remove/);
    ($name, $OTU)=split ("\t", $line);
    if ($name=~/\#([A-z]+)\/*[0-9]*$/){
	($bar)=$name=~/\#([A-z]+)\/*[0-9]*$/;
	if ($barhash{$bar}){
	    ($lib)=$barhash{$bar};
	    $OTUhash{$OTU}{$lib}++;
	} else {
	    die "Missing bar $bar in barcode file\n";
	}
    } else {
	die "Don't recognize the barcore in the name $name\n";
    }
}
close (IN);

foreach $OTU (sort keys%OTUhash){
    print "OTU";
    foreach $lib (sort keys %alllib){
	print "\t$lib";
    }
    print "\n";
    last;
}

foreach $OTU (sort keys %OTUhash){
    print "$OTU";
    foreach $lib (sort keys %alllib){
	if ($OTUhash{$OTU}{$lib}){
	    print "\t$OTUhash{$OTU}{$lib}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}
sub revcomp{
    my(@pieces);
    (@pieces) = split ("", $rc_seq);
    #make reverse complement
    $j = @pieces;
    $j-=1;
    $seq = ();
    until ($j < 0){
	if ($pieces[$j]){
	    if ($pieces[$j] eq "A"){
		if ($seq){
		    $seq = "$seq"."T";
		} else {
		    $seq="T";
		}
	    } elsif ($pieces[$j] eq "T"){
		if ($seq){
		    $seq = "$seq"."A";
		} else {
		    $seq="A";
		}
	    } elsif ($pieces[$j] eq "C"){
		if ($seq){
		    $seq = "$seq"."G";
		} else {
		    $seq="G";
		}
	    } elsif ($pieces[$j] eq "G"){
		if ($seq){
		    $seq = "$seq"."C";
		} else {
		    $seq="C";
		}
	    } elsif ($pieces[$j] eq "N"){
		if ($seq){
		    $seq = "$seq"."N";
		} else {
		    $seq="N";
		}
	    } else {
		die "RC NO Piece: $pieces[$j]\n";
	    }
	} else {
	    die "NO j $j\n";
	}
	$j--;
    }
    return ($seq);
}
