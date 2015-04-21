#! /usr/bin/perl -w
#
#

	die "Usage: Have both the chimera and the UC files in the same folder
UC_base_concat UC_base_f UC_base_r concat_fasta_full output\n" unless (@ARGV);
	($file1, $file2, $file3, $file4, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($output);
chomp ($file1);
chomp ($file2);
chomp ($file3);
chomp ($file4);
chomp ($output);

open (IN, "<${file1}.slayer.chimeras") or die "Can't open ${file1}.slayer.chimeras\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		next if ($line=~/^Name/);
		($name, @rest) = split("\t", $line);
		($shrt_name)=$name=~/^[0-9]+\|\*\|(.+)$/;
		if ($rest[0] eq "no"){
		    #the seed is not chimeric
		    $chimerafree{"concat"}{$shrt_name}++;
		} elsif ($rest[8] eq "no"){
		    #also not chimeric
		    $chimerafree{"concat"}{$shrt_name}++;
		} elsif ($rest[8] eq "yes"){
		    #it's a chimera
		    $chimera{"concat"}{$shrt_name}++;
		} else {
		    #messed up the tabs
		    print "DEAD: |${name}| |${rest[0]}| |${rest[9]}|\n";
		}
       	}
	close (IN);

open (IN, "<${file2}.slayer.chimeras") or die "Can't open ${file2}.slayer.chimeras\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/^Name/);
    ($name, @rest) = split("\t", $line);
    ($shrt_name)=$name=~/^[0-9]+\|\*\|(.+)$/;
    if ($rest[0] eq "no"){
                    #the seed is not chimeric                                                                                        
	$chimerafree{"f"}{$shrt_name}++;
    } elsif ($rest[8] eq "no"){
                    #also not chimeric                                                                                               
	$chimerafree{"f"}{$shrt_name}++;
    } elsif ($rest[8] eq "yes"){
                    #it's a chimera                                                                                                  
	$chimera{"f"}{$shrt_name}++;
    } else {
                    #messed up the tabs                                                                                              
	print "DEAD: |${name}| |${rest[0]}| |${rest[9]}|\n";
    }
}
close (IN);
open (IN, "<${file3}.slayer.chimeras") or die "Can't open ${file3}.slayer.chimeras\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/^Name/);
    ($name, @rest) = split("\t", $line);
    ($shrt_name)=$name=~/^[0-9]+\|\*\|(.+)$/;
    if ($rest[0] eq "no"){
                    #the seed is not chimeric                                                                                        
	$chimerafree{"r"}{$shrt_name}++;
    } elsif ($rest[8] eq "no"){
                    #also not chimeric                                                                                               
	$chimerafree{"r"}{$shrt_name}++;
    } elsif ($rest[8] eq "yes"){
                    #it's a chimera                                                                                                  
	$chimera{"r"}{$shrt_name}++;
    } else {
                    #messed up the tabs                                                                                              
	print "DEAD: |${name}| |${rest[0]}| |${rest[9]}|\n";
    }
}
close (IN);

open (IN, "<$file1") or die "Can't open $file1\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/^\#/);
    next if ($line=~/^C/);
    ($type, $seed, $len, $one, $two, $three, $four, $five, $name, $seedname)=split (" ", $line);
    if ($type eq "S"){
	$seedname = $name;
    }
    if ($chimera{"concat"}{$seedname}){
	#it's a chimera in concat
	$finalchimera{$name}++;
    }
}
close (IN);

open (IN, "<$file2") or die "Can't open $file2\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/^\#/);
    next if ($line=~/^C/);
    ($type, $seed, $len, $one, $two, $three, $four, $five, $name, $seedname)=split (" ", $line);
    if ($type eq "S"){
        $seedname = $name;
    }
    if ($chimera{"f"}{$seedname}){
        $finalchimera{$name}++;
    }
    unless ($seedname=~/^HWI/){
	$mockname{$name}=$seedname;
    }
}
close (IN);

open (IN, "<$file3") or die "Can't open $file3\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    next if ($line=~/^\#/);
    next if ($line=~/^C/);
    ($type, $seed, $len, $one, $two, $three, $four, $five, $name, $seedname)=split (" ", $line);
    if ($type eq "S"){
        $seedname = $name;
    }
    if ($chimera{"r"}{$seedname}){
	#it's a chimera in concat                                                                                                    
        $finalchimera{$name}++;
    }
    $total{$name}++;
}
close (IN);

$/=">";
open (OUTN, ">${output}.nonchimera.fa") or die "Can't open ${output}.nonchimera.fa\n";
open (OUTR, ">${output}.chimerareport") or die "Can't open ${output}.chimerareport\n";

open (IN, "<${file4}") or die "Can't open $file4\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    ($name, @seqs) = split ("\n", $line);
    ($seq) = join ("", @seqs);
    if ($finalchimera{$name}){
        print OUTR "$name\tChimera\t";
    } else {
        print OUTR "$name\tNon-chimera\t";
        print OUTN ">$name\n$seq\n\n";
    }
    if ($mockname{$name}){
        print OUTR "Mock\t$mockname{$name}\n";
    } else {
        print OUTR "Not Mock\tNA\n";
    }

}
close (IN);

close (OUTR);
close (OUTN);
