#! /usr/bin/perl -w

die "Use this for AdaptML to remove something
Usage: blastmap > redirect\n" unless (@ARGV);
($file) = (@ARGV);
chomp ($file);


open (IN, "<$file" ) or die "Can't open $file\n";
while ($line =<IN>){
    chomp ($line);
    next unless ($line);
    if ($line=~/QIIME/){
	next;
    }
    ($info, @seqs)=split ("\t", $line);
    if (@headers){
	($blast)=pop(@seqs);
	($org)=$blast=~/^(.+)_[0-9]_[0-9]_[0-9]$/;
	$hash{$org}++;
    } else {
	(@headers)=@seqs;
    }

}
close (IN);

foreach $org (sort keys %hash){
    print "$org\t$hash{$org}\n";
}
