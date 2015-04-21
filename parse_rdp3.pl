#! /usr/bin/perl -w
#
#

	die "Usage: RDP_file > redirect\n" unless (@ARGV);
	($file2) = (@ARGV);

	die "Please follow command line args\n" unless ($file2);

chomp ($file2);

$/=">";

open (IN, "<$file2") or die "Can't open $file2\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($name, $rdp)=split ("\n", $line);
		($newname)=$name=~/^(.+) reverse=/;
		(@seqs) = split (";", $rdp);
		$i=0;
		$conclass = ();
		$j = @seqs;
		until ($i > $j){
		    if ($seqs[$i]){
			$seqs[$i]=~s/ //g;
			if ($seqs[$i]){
			    if ($conclass){
				$conclass = "$conclass"."_"."$seqs[$i]";
			    } else {
				$conclass = $seqs[$i];
			    }
			    $i+=2;
			} else {
			    $i+=2;
			}
		    } else {
			$i+=2;
		    }
		}
		print "$newname\t$conclass\n";
       	}
close (IN);

