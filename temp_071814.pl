#! /usr/bin/perl -w

die "Usage: map> redirect\n" unless (@ARGV);
($merge) = (@ARGV);
chomp ($merge);

open (IN, "<$merge" ) or die "Can't open $merge\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    (@pieces)=split ("\t", $line);
    ($droplet)=$pieces[0]=~/droplet_bc=(.+)$/;
    ($id, $group)=$pieces[1]=~/(ID[0-9]+M)_(.+)/;
    $hash{$droplet}{$group}{$id}++;
}

close (IN);

foreach $droplet (sort keys %hash){
    print "$droplet";
    foreach $group (sort keys %{$hash{$droplet}}){
	print "\t$group";
	foreach $id (sort keys %{$hash{$droplet}{$group}}){
	    print "\t$id\t$hash{$droplet}{$group}{$id}";
	}
    }
    print "\n";
}
