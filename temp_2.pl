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

$workinfo = "HWUSI-EAS1563_0022:1:1:5716:14726#GCTATACCCTTCTT";
$workingseq = $hash{$workinfo};
($frontseq) = $workingseq=~/(T-------AC---GT-AG-GGT.+-------------------C-C)/;
#$i = 1;
#need to figure out which positions are the 2429 out of 50000 that we want for front seq and do the same for the back seq
#(@bps)=split ("", $workingseq);
#$cap=@bps;

#until ($i > $cap){
#    ($checkseq1) = $workingseq=~/^.{$i}(.{2424})/;
#    die "Not ckeckseq1\n" unless ($checkseq1);#

#    if ($checkseq1 eq $frontseq){
#	print "These are your front positions: $i 2424\n";
#	$front=$i;
#    }
#    $i++;
#}

foreach $info (keys %hash){
    ($frontend) = $hash{$info}=~/^.{1970}(.{2424})/;
    $newseq = "$frontend";
    print ">$info\n$newseq\n\n";
}
