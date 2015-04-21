#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: all all_mat map > redirect\n" unless (@ARGV);
	
chomp (@ARGV);
($all, $mat, $map) = (@ARGV);


open (IN, "<${all}") or die "Can't open $all\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $ref)=split ("\t", $line);
    $hash{$ref}=$name;
}
close (IN);

open (IN, "<${mat}") or die "Can't open ${mat}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @pieces)=split ("\t", $line);
    if (@headers){
	$i=0;
	$j=@pieces;
	until ($i >=$j){
	    $mathash{$name}{$headers[$i]}=$pieces[$i];
	    $i++;
	}
    } else {
	@headers=@pieces;
        $i=0;
        $j=@headers;
        until ($i >=$j){
	    $allheaders{$headers[$i]}++;
            $i++;
        }
    }
}
close (IN);

open (IN, "<${map}") or die "Can't open $map\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @refs)=split ("\t", $line);
    $matching=@refs;
    if ($matching>1){
	foreach $ref (@refs){
	    $inhash{$name}{$ref}++;
	}
    }
}
close (IN);

print "OTU\tRef";
foreach $header (sort keys %allheaders){
    print "\t$header";
}
print "\n";
foreach $name (sort keys %inhash){
    print "$name\n";
    foreach $ref (sort keys %{$inhash{$name}}){	
	print "$hash{$ref}\t$ref";
	foreach $head (sort keys %allheaders){
	    if ($mathash{$hash{$ref}}{$head}){
		print "\t$mathash{$hash{$ref}}{$head}";
	    } else {
		print "\t0";
	    }
	}
	print "\n";
    }
}
