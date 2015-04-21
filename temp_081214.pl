#! /usr/bin/perl -w

die "Usage: trans Ground Reactors > redirect\n" unless (@ARGV);
($trans, $Gmat, $Rmat) = (@ARGV);
chomp ($tran, $Gmat, $Rmat);

open (IN, "<${trans}") or die "Can't open ${trans}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($well, $R1, $R2, $R3)=split ("\t", $line);
    $wellhash{$well}++;
    $R1hash{$R1}=$well;
    $R2hash{$R2}=$well;
    $R3hash{$R3}=$well;
}
close (IN);


open (IN, "<$Gmat" ) or die "Can't open $Gmat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @counts)=split ("\t", $line);
    next if ($OTU eq "Total");
    if (@headers){
	$i=0;
	$j=@counts;
	until ($i >=$j){
	    $Gmathash{$headers[$i]}{$OTU}=$counts[$i];
	    $i++;
	}
    } else {
	(@headers)=@counts;
    }
	
}

close (IN);

@headers=();

open (IN, "<$Rmat" ) or die "Can't open $Rmat\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @counts)=split ("\t", $line);
    next if ($OTU eq "Total");
    if (@headers){
        $i=0;
        $j=@counts;
        until ($i >=$j){
            $Rmathash{$OTU}{$headers[$i]}=$counts[$i];
            $i++;
        }
    } else {
        (@headers)=@counts;
    }
}
close (IN);

