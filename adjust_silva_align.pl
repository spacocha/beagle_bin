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

$workinfo = "AJ582031.1";
$workingseq = $hash{$workinfo};
($frontseq) = $workingseq=~/(A\-*U\-*A\-*C\-*G\-*A\-*A\-*G\-*G\-*G.*A\-*G\-*G\-*G\-*C\-*U\-*C\-*A\-*A\-*C\-*C\-*C\-*U)/;
($backseq) = $workingseq=~/(G-*C-*A-*U-*G-*C-*A-*U-*G-*C-*A-*U-*G-*U-*C-*G-*G-*U.*U-*U-*A-*A-*A-*A-*C-*U-*C-*A-*A-*A-*G-*G-*A-*A-*U-*U)/;
$i = 1;
#need to figure out which positions are the 2429 out of 50000 that we want for front seq and do the same for the back seq
    
until ($i > 50000){
    ($checkseq1) = $workingseq=~/^.{$i}(.{2429})/;
    ($checkseq2) = $workingseq=~/^.{$i}(.{2290})/;
    die "Not ckeckseq1\n" unless ($checkseq1);
    die "No checkseq2\n" unless ($checkseq2);

    if ($checkseq1 eq $frontseq){
	#print "These are your front positions: $i 2429\n";
	$front=$i;
    }
    if ($checkseq2 eq $backseq){
	#print "These are your back positions: $i 2290\n";
	$back = $i;
	$i = 50000;
    }
    $i++;
}

foreach $info (keys %hash){
    ($frontend) = $hash{$info}=~/^.{$front}(.{2429})/;
    ($backend) = $hash{$info}=~/^.{$back}(.{2290})/;
    $newseq = "$frontend"."$backend";
    print ">$info\n$newseq\n\n";
}
