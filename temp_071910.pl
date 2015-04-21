#! /usr/bin/perl -w
#
#

	die "Usage: UC_file Fasta_file > Redirect\n" unless (@ARGV);
	($file1, $file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);
chomp ($file1);
chomp ($file2);

$/=">";
	open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, @seqs)=split ("\n", $line);
		($seq) = join ("", @seqs);
		die "Short seq: $seq\n" unless ($seq=~/.{172}/);
		$hash{$name}=$seq;
       	}
	close (IN);

$/="\n";
%inhash = (27, 1, 3, 1, 73, 1, 69, 1, 29, 1, 82, 1, 64, 1, 62, 1, 53, 1, 74 ,1, 61 ,1, 65, 1, 70, 1, 45, 1, 23, 1, 51, 1, 32 ,1);

open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/^#/);
    ($type, $seed, $len, $one, $two, $three, $four, $five, $name, $seedname)=split (" ", $line);
    if ($type eq "S"){
	if ($hash{$name}){
	    $counthash{$seed}++;
	    print ">A${seed}_${counthash{$seed}}\n$hash{$name}\n" if ($counthash{$seed}<6 && $inhash{$seed});
	} else {
	    die "No seq $name\n";
	}
    } elsif ($type ne "C"){
	if ($hash{$name}){
	    $counthash{$seed}++;
	    print ">A${seed}_$counthash{$seed}\n$hash{$name}\n" if ($counthash{$seed}<6 && $inhash{$seed});
	} else {
	    die "No seq $name $line\n";
	}

    }
}
close (IN);


 
