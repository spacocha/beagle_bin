#! /usr/bin/perl -w

die "Usage: Solexa1 Solexa2 filesize  count_needed output\n" unless (@ARGV);
($sol1, $sol2, $size, $count, $output) = (@ARGV);
chomp ($sol1);
chomp ($sol2);
chomp ($size);
chomp ($count);
chomp ($output);

$i = 1;
until ($i > $count){
    $got = ();
    until ($got){
	($random) = int(rand($size));
	if ($hash{$random}){
	    $got=();
	} else {
	    $hash{$random}++;
	    $got++;
	}
    }
    $i++;
}

$/="@";
$i=1;
open (IN1, "<$sol1" ) or die "Can't open $sol1\n";
open (IN2, "<$sol2" ) or die "Can't open $sol2\n";
open (OUT1, ">${output}.1.shrt" ) or die "Can't open ${output}.1.shrt\n";
open (OUT2, ">${output}.2.shrt" ) or die "Can't open ${output}.2.shrt\n";
while ($line =<IN1>){
    chomp ($line);
    ($line2=<IN2>);
    chomp ($line2);
    next unless ($line && $line2);
    if ($hash{$i}){
	(@pieces)=split ("\n", $line);	
	$first=1;
	foreach $piece (@pieces){
	    if ($first){
		print OUT1 "\@$piece\n";
		$first=();
	    } else {
		print OUT1 "$piece\n";
	    }
	}
	(@pieces2)=split ("\n", $line2);
        $first=1;
        foreach $piece (@pieces2){
            if ($first){
                print OUT2 "\@$piece\n";
		$first=();
	    } else {
		print OUT2 "$piece\n";
            }
	}
    }
    $i++;
} 
close (IN1);
close (IN2);

close (OUT1);
close (OUT2);
