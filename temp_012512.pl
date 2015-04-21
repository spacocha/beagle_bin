#! /usr/bin/perl -w

die "Usage: file > redirect\n" unless (@ARGV);

($mat)=(@ARGV);
chomp ($mat);
open (IN, "<$mat" ) or die "Can't open $mat\n";
$first=1;
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @p)=split ("\t", $line);
    if ($first){
	@h=@p;
	$first=();
	print "OTU";
	foreach $piece (@p){
	    if ($piece=~/mix2/ || $piece=~/mix5/ || $piece=~/mix8/){
		#nothing
		$o=0;
	    } else {
		print "\t$piece";
	    }
	}
	print "\n";
    } else {
	$i=0;
	$j=@p;
	print "$OTU";
	until ($i >=$j){
	    if ($h[$i]=~/mix4/ || $h[$i]=~/mix5/ || $h[$i]=~/mix6/){
		#nothing
		$o=0;
	    } else {
		print "\t$p[$i]";
	    }
	    $i++;
	}
	print "\n";
    }
}
close (IN);


