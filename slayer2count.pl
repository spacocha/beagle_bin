#! /usr/bin/perl -w
#
#

	die "Usage: Slayer_file Count_file RDP_file > Redirect\n" unless (@ARGV);
	($file1, $file2, $file3) = (@ARGV);

	die "Please follow command line args\n" unless ($file3);
chomp ($file1);
chomp ($file2);
chomp ($file3);


open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($fastaname, @pieces)=split ("\t", $line);
    ($shrt_name) = $fastaname=~/^[0-9]+\|\*\|(.+)$/;
    if ($pieces[0] eq "no"){
	$chimera{$shrt_name}="no";
	$data{$shrt_name}="NA";
    } elsif ($pieces[8] eq "no"){
	$chimera{$shrt_name}="no";
	$data{$shrt_name}="NA";
    } elsif ($pieces[8] eq "yes"){
	$chimera{$shrt_name}="yes";
	$data{$shrt_name}="$line";
    }
}
close (IN);

$/=">";
open (IN, "<$file3") or die "Can't open $file3\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($fastaname, $class) = split ("\n", $line);
    ($shrt_name) =$fastaname=~/^[0-9]+\|\*\|(.+) reverse/;
    ($cl1, $cl1no, $cl2, $cl2no, $cl3, $cl3no, $cl4, $cl4no, $cl5, $cl5no, $cl6, $cl6no, $cl7, $cl7no) = split (";", $class);
    (${concat_class})="$cl1"."_"."$cl2"."_"."$cl3"."_"."$cl4"."_"."$cl5"."_"."$cl6"."_"."$cl7";
    $ref = ();
    $ref = 1 unless (${shrt_name}=~/^HWI/);
    $classhash{$shrt_name}=${concat_class};
    $refclass{$concat_class}=${shrt_name} if ($ref);
}
close (IN);

$/="\n";

open (IN, "<$file2") or die "Can't open $file2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($fastaname, $count)=split ("\t", $line);
    if ($chimera{$fastaname}){
	if ($chimera{$fastaname} eq "yes"){
	    $chimeracount+=$count;
	    #it's a chimera, so I don't really care about it
	    print "$fastaname\t$chimera{$fastaname}\t$count\tNA\t";
	    if ($classhash{$fastaname}){
		print "$classhash{$fastaname}\t";
	    } else {
		print "Missing\t";
	    }
	    print "$data{$fastaname}\n";
	} elsif ($chimera{$fastaname} eq "no"){
	    print "$fastaname\t$chimera{$fastaname}\t$count\t";
	    if ($classhash{$fastaname}){
		if ($refclass{$classhash{$fastaname}}){
		    print "mock\t$classhash{$fastaname}\t";
		    $mockcount{$refclass{$classhash{$fastaname}}}+=$count;
		    $inmockcount+=$count;
		} else {
		    print "non-mock\t$classhash{$fastaname}\t";
		    $notmockcount+=$count;
		}
	    } else {
		print "NA\tmissing\t";
		$notmockcount+=$count;
	    }
		print "$data{$fastaname}\n";
	}
    }
}
close (IN);

foreach $mock (sort {$mockcount{$b} <=> $mockcount{$a}} keys %mockcount){
    print "$mock\t$mockcount{$mock}\n";

}
print "In mock: $inmockcount
Not in-mock: $notmockcount
Chimera: $chimeracount\n";
