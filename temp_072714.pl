#! /usr/bin/perl -w

die "Usage: all_files> redirect\n" unless (@ARGV);
chomp (@ARGV);

$/=">";
foreach $file (@ARGV){
    open (IN, "<$file" ) or die "Can't open $file\n";
    while ($line =<IN>){
	chomp ($line);
	next unless ($line);
	($info, @seqs)=split ("\n", $line);
	($sequence)=join ("", @seqs);
	($sample, $illumina)=$info=~/^(.+?)_[0-9]+ (.+#[A-z]{7,15})/;
	die "Missing one sample $sample illumina $illumina\n$line" unless ($sample && $illumina);
	if ($hash{$illumina}){
	    if ($sample eq $hash{$illumina}){
		#nothing it's the same thing
	    } else {
		print ">${info}\n${sequence}\n";
	    }
	} else {
	    $hash{$illumina}=$sample;
	    print ">${info}\n${sequence}\n";
	}
    }
    close (IN);
}
