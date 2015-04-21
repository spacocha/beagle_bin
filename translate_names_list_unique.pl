#! /usr/bin/perl
#
#

	die "Usage: trans list  > redirect\n" unless (@ARGV);
	($trans, $list) = (@ARGV);

	die "Please follow command line args\n" unless ($list);
chomp ($trans);
chomp ($list);

open (IN1, "<$trans") or die "Can't open $trans\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($name, $unique)=split ("\t", $line1);
    ($shrt)=$name=~/^(.+?)$/;
    $hash{$shrt}=$unique;
}
close (IN1);

open (IN1, "<$list") or die "Can't open $list\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($id, @seqs)=split ("\t", $line1);
    print "$id";
    foreach $seq (@seqs){
	if ($hash{$seq}){
	    if ($done{$hash{$seq}}){
		die "same unique in different id $id unique $hash{$seq} recorded id $done{$hash{$seq}} name $seq\n" unless ($id eq $done{$hash{$seq}});;
	    } else {
		print "\t$hash{$seq}";
		$done{$hash{$seq}}=$id;
	    }
	}else {
	    die "Missing unqiue for name $seq\n";
	}
    }
    print "\n";
}
close (IN1);
