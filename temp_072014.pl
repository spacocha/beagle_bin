#! /usr/bin/perl -w

die "Usage: uc_file final.fa> redirect\n" unless (@ARGV);
($uc, $fa) = (@ARGV);
chomp ($uc, $fa);


$/=">";
open (IN, "<$fa" ) or die "Can't open $fa\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\n", $line);
    ($seq)=join ("", @pieces);
    $hash{$OTU}=$seq;
}

close (IN);
$/="\n";
open (IN, "<$uc" ) or die "Can't open $uc\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    ($ID)=$pieces[8]=~/^(seq[0-9]+);/;
    $openhash{$pieces[1]}{$pieces[8]}++ if ($hash{$ID});
}

foreach $openID (sort keys %openhash){
    $dup=();
    foreach $ID (sort keys %{$openhash{$openID}}){
	if ($dup){
	    print "$openID\t$save\t$ID\n";
	} else {
	    $save=$ID;
	    $dup++;
	}
    }
}
