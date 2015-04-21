#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: inputfiles,comma,sep output\n" unless (@ARGV);
	
	chomp (@ARGV);
($files, $output)=(@ARGV);
print "FILEs: $files OUTPUT $output\n";
(@splitfiles)=split (",", $files);
$/ = ">";
$OTUc=1;
open (OUT, ">${output}.trans") or die "Can't open $output\n";
foreach $file (@splitfiles){
    print "Opening $file\n";
    open (IN, "<$file") or die "Can't open $file\n";
    while ($line1 = <IN>){	
	chomp ($line1);
	next unless ($line1);
	$sequence = ();
	(@pieces) = split ("\n", $line1);
	($info) = shift (@pieces);
	if ($info=~/_[0-9]+$/){
	    ($newinfo)=$info=~/^(.+)_[0-9]+$/;
	} else {
	    $newinfo=$info;
	}
	($sequence)=join ("", @pieces);
	if ($hash{$sequence}){    
	    print OUT "$file\t$newinfo\t$hash{$sequence}\n";
	} else {
	    (@piecesc) = split ("", $OTUc);
	    $these = @piecesc;
	    $zerono = 7 - $these;
	    $zerolet = "0";
	    $zeros = $zerolet x $zerono;
	    $OTUn="ID${zeros}${OTUc}Q";
	    $OTUc++;
	    $hash{$sequence}=$OTUn;
	    print OUT "$file\t$newinfo\t$hash{$sequence}\n";
	}
    }
    close (IN);
}

close (OUT);
open (OUT, ">${output}.fa") or die "Can't open ${output}.fa\n";
foreach $seq (sort keys %hash){
    print OUT ">$hash{$seq}\n$seq\n";
}
