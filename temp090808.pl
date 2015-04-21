#! /usr/bin/perl -w

die "Usage: <pop_dir list of file> > redirect" unless (@ARGV);
($dir) = (@ARGV);
chomp ($dir);

open (IN1, "<$dir") or die "Can't open ${dir}\n";
while ($line1 = <IN1>){
    chomp ($line1);
    open (IN, "<./pop_dir/${line1}" ) or die "Can't open ./pop_dir/${line1}\n";
    while ($line =<IN>){
	chomp ($line);
	($isolate, $hab, $pop)= split ("\t", $line);
	$pophash{$line1}{$isolate}=$pop;
	$pophash2{$isolate}{$line1}=$pop;
	$habhash{$line1}{$isolate}=$hab;
	$habhash2{$isolate}{$line1}=$hab;    
    }
    close (IN);
}
close (IN1);

foreach $file (keys %pophash){
    foreach $isolate (keys %{$pophash{$file}}){
	foreach $otherisolate (keys %{$pophash{$file}}){
	    next if ($isolate eq $otherisolate);
	    if ($habhash{$file}{$isolate} == $habhash{$file}{$otherisolate}){
	        $samehab{$isolate}{$otherisolate}++;
	    } else {
		$diffhab{$isolate}{$otherisolate}++;
	    }
	   if ($pophash{$file}{$isolate} == $pophash{$file}{$otherisolate}){
		 #count the number of times they are in the same population in the other file
		 $samepop{$isolate}{$otherisolate}++;
	     } else {
		 $diffpop{$isolate}{$otherisolate}++;
	    }
	}
    }
}

foreach $isolate (keys %samepop){
    foreach $otherisolate (keys %{$samepop{$isolate}}){
	if ($samepop{$isolate}{$otherisolate} > 95){
	    $unquestionable{$isolate}{$otherisolate}++;
	    $seventyfive++;
	} elsif ($samepop{$isolate}{$otherisolate} > 50){
	    $fifty++;
	} elsif ($samepop{$isolate}{$otherisolate} > 25){
	    $twentyfile++;
	} else {
	    $zero++;
	}
    }
}

foreach $isolate (keys %samehab){
    foreach $otherisolate (keys %{$samehab{$isolate}}){
        if ($samehab{$isolate}{$otherisolate} > 75){
            $seventyfive2++;
        } elsif ($samehab{$isolate}{$otherisolate} >50){
            $fifty2++;
        } elsif ($samehab{$isolate}{$otherisolate} > 25){
            $twentyfile2++;
        } else {
            $zero2++;
        }
    }
}

$newpopcount=();
%newpops=();
foreach $isolate (keys %unquestionable){
    foreach $otherisolate (keys %{$unquestionable{$isolate}}){
	if ($newpops{$isolate}){
	    if ($newpops{$otherisolate}){
		#they are already marked for some reason
	    } else {
		#the other isn't marked
		$newpops{$otherisolate}=$newpops{$isolate};
	    }
	} elsif ($newpops{$otherisolate}){
	    if ($newpops{$isolate}){
		#both are already marked again?
	    } else {
		$newpops{$isolate}=$newpops{$otherisolate};
	    }
	} else {
	    #neither are already labeled
	    $newpopcount++;
	    $newpops{$isolate}=$newpopcount;
	    $newpops{$otherisolate}=$newpopcount;
	}
    }
}

foreach $isolate (sort {$a <=> $b} keys %newpops){
    print "$isolate\t$newpops{$isolate}\n";
}
