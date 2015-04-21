#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: <input_file> Redirect output\n" unless (@ARGV);
	
	chomp (@ARGV);
	($file) = (@ARGV);
	$/ = ">";
	open (IN, "<$file") or die "Can't open $file\n";
	while ($line1 = <IN>){	
		chomp ($line1);
		next unless ($line1);
		$sequence = ();
		(@pieces) = split ("\n", $line1);
		($info) = shift (@pieces);
		($sequence) = join ("", @pieces);
		$sequence =~tr/\n//d;
		$hash{$info}=$sequence;


	}
	
	close (IN);

#$workinfo = "AJ582031.1";
#$workingseq = $hash{$workinfo};
#($frontseq) = $workingseq=~/([AUGC]-*G-*U-*G-*C-*C-*A-*G-*C-*A*-*G-*C-*C-*G-*C-*G-*G-*U-*A-*A-*.+A-*U-*-U-*A-*G-*A-*U-*A-*C-*C-*C-*U-*G-*G-*U-*A-*G-*U-*C-*C-*A-*[AUCG])/;
#how long are each of the sequences
#(@fc) = split ("", $frontseq);
#$fcount = @fc;
#$i = 1;
#need to figure out which positions are the 2429 out of 50000 that we want for front seq and do the same for the back seq
    
#until ($i > 50000){
#    ($checkseq1) = $workingseq=~/^.{$i}(.{$fcount})/;
#    die "Not ckeckseq1\n" unless ($checkseq1);##

#    if ($checkseq1 eq $frontseq){
#	die "These are your front positions: $i $fcount\n";
#	$front=$i;
#    }
#    $i++;
#}

foreach $info (keys %hash){
    ($frontend) = $hash{$info}=~/^.{11891}(.{13541})/;
    print ">$info\n$frontend\n\n";
}
