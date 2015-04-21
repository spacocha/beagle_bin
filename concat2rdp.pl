#! /usr/bin/perl -w
#
#

	die "Usage: concat.fa> Redirect\n" unless (@ARGV);
	($file1) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
$/=">";
$i = 0;
$N = "N";
until ($i > 216){
    push (@Ns, $N);
    $i++;
}
$string = join ("", @Ns);
die "$string\n" unless ($string =~/^N{217}$/);

	open (IN, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($seedname, @seqs)=split ("\n", $line);
		($sequence) = join ("", @seqs);
		die "Not 172 bps: $seedname\n$sequence\n" unless ($sequence =~/^.{46}.{46}.{40}.{40}$/);
		($div1, $div2) = $sequence =~/^(.{92})(.{80})$/;
		print ">${seedname}\n${div1}${string}${div2}\n\n";
       	}
	close (IN);
