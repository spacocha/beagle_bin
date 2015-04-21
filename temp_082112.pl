#! /usr/bin/perl -w
#
#

	die "Usage: fasta_file1 matfile_with_fasta1_names fasta_file2 > matfile_with_fasta1_names\n" unless (@ARGV);
	
chomp (@ARGV);
($file1, $matfile, $file2) = (@ARGV);

$/=">";
open (IN, "<${file1}") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs)=split ("\n", $line);
    ($sequence)=join ("", @seqs);
    if ($hash1{$sequence}){
	die "The program can only make a comparison between files that contain only unique sequences. $info and $hash1{$sequence} have the same seqeunce ($sequence)\n";
    }
    $hash1{$sequence}=$info;
    $namehash1{$info}=$sequence;
}
close (IN);

open (IN, "<${file2}") or die "Can't open $file2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($info, @seqs)=split ("\n", $line);
    ($sequence)=join ("", @seqs);
    if ($hash2{$sequence}){
        die "The program can only make a comparison between files that contain only unique sequences. $info and $hash2{$sequence} have the same seqeunce ($sequence)\n";
    }

    $hash2{$sequence}=$info;
}
close (IN);

$/="\n";
@headers=();
open (IN, "<${matfile}") or die "Can't open $matfile\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($OTU, @libs)=split ("\t", $line);
    if (@headers){
	if ($namehash1{$OTU}){
	    ($seq)=$namehash1{$OTU};
	    if ($hash2{$seq}){
		print "$hash2{$seq}";
		$i = 0;
		$j = @headers;
		until ($i >=$j){
		    print "\t$libs[$i]";
		    $i++;
		}
		print "\n";
	    } 
	} else {
	    die "Missing sequence for $OTU $namehash1{$OTU}\n";
	}
    } else {
	(@headers)=@libs;
	$i=0;
	$j=@headers;
	print "OTU";
	until ($i >= $j){
	    print "\t$headers[$i]";
	    $i++;
	}
	print "\n";
    }
}
close (IN);
