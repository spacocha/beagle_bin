#! /usr/bin/perl -w
#
#

	die "Usage: RDP_file tab_w_UC\n" unless (@ARGV);
	($file2, $tab) = (@ARGV);

	die "Please follow command line args\n" unless ($tab);

chomp ($file2);
chomp ($tab);

$/=">";

open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, $rdp)=split ("\n", $line);
		($UC) = $name =~/^(.+) reverse/;
		(@seqs) = split (";", $rdp);
		$i=0;
		$conclass = ();
		$j = @seqs;
		until ($i > $j){
		    if ($conclass){
			$seqs[$i]=~s/ //g;
			$conclass = "$conclass"."_"."$seqs[$i]" if ($seqs[$i]);
		    } else {
			$seqs[$i]=~s/ //g;
			$conclass = $seqs[$i];
		    }
		    $i+=2;
		}
		if ($UC && $conclass){
		    $hash{$UC}=$conclass;
		} else {
		    die "UC: $UC CON:$conclass\n$line\n";
		}
       	}
close (IN);

$/="\n";
open (IN, "<$tab") or die "Can't open $tab\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, $lib, $fseq, $fqual, $rseq, $rqual, $UC, $UC2, $OTU)= split ("\t", $line);
    if ($hash{$UC}){
	print "$name\t$lib\t$fseq\t$fqual\t$rseq\r$rqual\t$UC\t$UC2\t$OTU\t$hash{$OTU}\n";
    }	else {
	print "$name\t$lib\t$fseq\t$fqual\t$rseq\r$rqual\t$UC\t$UC2\t$OTU\tremoved\n";
    }

}
    
close (IN);
