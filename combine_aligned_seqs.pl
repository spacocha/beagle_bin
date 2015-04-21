#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: forward_file reverse_file > Redirect output\n" unless (@ARGV);
	
	chomp (@ARGV);
	($file1, $file2) = (@ARGV);
	$/ = ">";
	open (IN, "<$file1") or die "Can't open $file1\n";
	while ($line1 = <IN>){	
		chomp ($line1);
		next unless ($line1);
		(@pieces) = split ("\n", $line1);
		($info) = shift (@pieces);
		$sequence=join ("", @pieces);
		$hash{$info}=$sequence;
	}
	
	close (IN);

        open (IN, "<$file2") or die "Can't open $file2\n";
        while ($line1 = <IN>){
                chomp ($line1);
                next unless ($line1);
                $sequence = ();
                (@pieces) = split ("\n", $line1);
                ($info) = shift (@pieces);
                ($sequence) = join ("", @pieces);
                $sequence =~tr/\n//d;
		if ($hash{$info}){
		    #there is a forward read for it
		    (@pieces1)=split ("", $hash{$info});
		    (@pieces2)=split ("", $sequence);
		    $i=0;
		    $j=@pieces1;
		    $k=@pieces2;
		    die "$pieces1 doesn't equal $pieces2 $j $k\n" unless ($j == $k);
		    $seq1end=0;
		    $seq2start=$j;
		    $joinseq=();
		    until ($i >=$j){
			#whats is in @pieces1 at position $i
			$base1=$pieces1[$i];
			$base2=$pieces2[$i];
			if ($base1 eq $base2 || ($base1 eq "-" && $base2 eq ".")){
			    if ($joinseq){
				$joinseq="$joinseq"."$base1";
			    } else {
				$joinseq=$base1;
			    }
			} elsif ($base1 eq "." && $base2 eq "-"){
			    if ($joinseq){
				$joinseq="$joinseq"."$base2";
			    } else {
                                $joinseq=$base2;
                            }
			} elsif ($base1=~/[ATGC]/){
			    if ($base2=~/[ATGC]/){
				die "Overlapping and wrong $base1 $base2 $i\n";
			    } else {
				if ($joinseq){
				    $joinseq="$joinseq"."$base1";
				} else {
				    $joinseq=$base1;
				}
			    }
			} elsif ($base2=~/[ATGC]/){
			    if ($joinseq){
				$joinseq="$joinseq"."$base2";
			    } else{
				$joinseq=$base2;
			    }
			} else {
			    die "Missing something $base1 $base2 $info $i\n";
			}
			$i++;
		    }
		    $hash2{$info}=$joinseq;
		}
	    }

        close (IN);	

foreach $info (sort keys %hash){
    if ($hash2{$info}){
	print ">$info\n$hash2{$info}\n";
    }
}
