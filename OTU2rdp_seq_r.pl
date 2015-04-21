#! /usr/bin/perl -w
#
#

	die "Use this program to take the tab file and make a matrix with the library counts
Usage: data_file >redirect\n" unless (@ARGV);
	($file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file2);

open (IN, "<${file2}") or die "Can't open ${file2}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $lib, $fseq, $fqual, $rseq, $rqual, $falign, $FreClu, $UC, $OTU, $ralign) = split ("\t", $line);
    next if ($ralign eq "removed" || $falign eq "removed");
    (@fpieces)=split ("", $falign);
    (@rpieces)=split ("", $ralign);
    $flen = @fpieces;
    $rlen = @rpieces;
    $i = 0;
    until ($i >=$flen){
	$fposhash{$OTU}{$i}{$fpieces[$i]}++;
	$fpostotal{$OTU}{$i}++;
	$i++;
    }
    $i=0;
    until ($i >=$rlen){
	$rposhash{$OTU}{$i}{$rpieces[$i]}++;
	$rpostotal{$OTU}{$i}++;
	$i++;
    }
}
close (IN);

foreach $OTU (sort keys %fposhash){
    foreach $pos (sort {$a <=> $b} keys %{$fposhash{$OTU}}){
	#need to get one 75% consensus base from each position
	$got=();
	$gap = ();
	foreach $base (sort keys %{$fposhash{$OTU}{$pos}}){
	    $gap++ if ($base eq "-");
	    $frac=$fposhash{$OTU}{$pos}{$base}/$fpostotal{$OTU}{$pos};
	    $fracgap=$frac if ($base eq "-");
	    if ($frac>0.75){
		$got++;
		$consensus{$OTU}{$pos}=$base;
	    }
	}
	#does this position have a consensus?
	unless ($got){
	    if ($gap){
		#if there is a gap, I just want to make sure that there aren't more than half with a gap (this might make the consensus weird)
		if ($fracgap < 0.25){
		    $consensus{$OTU}{$pos}="N";
		} elsif ($fracgap > 0.5) {
		    #looks like a gap
		    $consensus{$OTU}{$pos}="-";
		} elsif ($fracgap < 0.5){
		    #looks like an N
		    $consensus{$OTU}{$pos}="n";
		} else {
		    #it is half (which is probably out of a small number)
		    $consensus{$OTU}{$pos}="N";
		}
	    } else {
		#figure out what bases are there
		%ambhash=();
		$ambase=();
		foreach $base (sort keys %{$fposhash{$OTU}{$pos}}){
		    $ambhash{$base}++;
		}
		if ($ambhash{"A"} && $ambhash{"C"} && $ambhash{"G"} && $ambhash{"T"}){
		    $ambase="N";
		} elsif ($ambhash{"A"} && $ambhash{"C"} && $ambhash{"G"}){
		    $ambase="V";
		} elsif ($ambhash{"A"} && $ambhash{"C"} && $ambhash{"T"}){
		    $ambase="H";
		} elsif($ambhash{"A"} && $ambhash{"G"} && $ambhash{"T"}){
                    $ambase="D";
		} elsif($ambhash{"C"} && $ambhash{"G"} && $ambhash{"T"}){
                    $ambase="B";
		} elsif($ambhash{"A"} && $ambhash{"C"}){
                    $ambase="M";
                } elsif($ambhash{"A"} && $ambhash{"G"}){
                    $ambase="R";
                } elsif($ambhash{"A"} && $ambhash{"T"}){
                    $ambase="W";
                } elsif($ambhash{"C"} && $ambhash{"G"}){
                    $ambase="S";
                } elsif($ambhash{"C"} && $ambhash{"T"}){
                    $ambase="Y";
                } elsif($ambhash{"G"} && $ambhash{"T"}){
                    $ambase="K";
		} else {
		    die "Amb key didn't work: F\n";
		}
		$consensus{$OTU}{$pos}=$ambase;
	    }
	}
    }
}

foreach $OTU (sort keys %rposhash){
    foreach $pos (sort {$a <=> $b} keys %{$rposhash{$OTU}}){
        #need to get one 75% consensus base from each position                                                                                                                                   
        $got=();
        $gap = ();
        foreach $base (sort keys %{$rposhash{$OTU}{$pos}}){
            $gap++ if ($base eq "-");
            $frac=$rposhash{$OTU}{$pos}{$base}/$rpostotal{$OTU}{$pos};
            $fracgap=$frac if ($base eq "-");
            if ($frac>0.75){
                $got++;
                $consensusr{$OTU}{$pos}=$base;
            }
        }
        #does this position have a consensus?                                                                                                                                                    
        unless ($got){
            if ($gap){
                #if there is a gap, I just want to make sure that there aren't more than half with a gap (this might make the consensus weird)                                                   
                if ($fracgap < 0.25){
                    $consensusr{$OTU}{$pos}="N";
                } elsif ($fracgap > 0.5) {
                    #looks like a gap                                                                                                                                                            
                    $consensusr{$OTU}{$pos}="-";
                } elsif ($fracgap < 0.5){
                    #looks like an N                                                                                                                                                             
                    $consensusr{$OTU}{$pos}="n";
                } else {
                    #it is half (which is probably out of a small number)                                                                                                                        
                    $consensusr{$OTU}{$pos}="N";
                }
	    } else {
		#figure out what bases are there
		%ambhash=();
		$ambase=();
		foreach $base (sort keys %{$rposhash{$OTU}{$pos}}){
		    $ambhash{$base}++;
		}
		if ($ambhash{"A"} && $ambhash{"C"} && $ambhash{"G"} && $ambhash{"T"}){
		    $ambase="N";
		} elsif ($ambhash{"A"} && $ambhash{"C"} && $ambhash{"G"}){
		    $ambase="V";
		} elsif ($ambhash{"A"} && $ambhash{"C"} && $ambhash{"T"}){
		    $ambase="H";
		} elsif($ambhash{"A"} && $ambhash{"G"} && $ambhash{"T"}){
                    $ambase="D";
		} elsif($ambhash{"C"} && $ambhash{"G"} && $ambhash{"T"}){
                    $ambase="B";
		} elsif($ambhash{"A"} && $ambhash{"C"}){
                    $ambase="M";
                } elsif($ambhash{"A"} && $ambhash{"G"}){
                    $ambase="R";
                } elsif($ambhash{"A"} && $ambhash{"T"}){
                    $ambase="W";
                } elsif($ambhash{"C"} && $ambhash{"G"}){
                    $ambase="S";
                } elsif($ambhash{"C"} && $ambhash{"T"}){
                    $ambase="Y";
                } elsif($ambhash{"G"} && $ambhash{"T"}){
                    $ambase="K";
		} else {
		    die "Amb key didn't work: R\n";
		}
		$consensus{$OTU}{$pos}=$ambase;
	    }
        }
    }
}

foreach $OTU (sort keys %consensus){
    print ">$OTU\n";
    foreach $positionf (sort {$a <=> $b} keys %{$consensus{$OTU}}){
	print "$consensus{$OTU}{$positionf}";
    }
    $len=238;
    $Xs=".";
    $Ns=$Xs x $len;
    print "$Ns";
    foreach $positionr (sort {$a <=> $b} keys %{$consensusr{$OTU}}){
	print "$consensusr{$OTU}{$positionr}";
    }
    print "\n";
}

		
