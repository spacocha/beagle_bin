#! /usr/bin/perl -w
#
#

	die "Usage: barfile_with_trans > Redirect\n" unless (@ARGV);
	($file1) = (@ARGV);

	die "Please follow command line args\n" unless ($file1);
chomp ($file1);


open (IN, "<$file1") or die "Can't open $file1\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		($trans, $bar) = split ("\t", $line);
		$bthash{$bar}=$trans;
		#record all the rdp classes for each library based on barcodes
		open (IN2, "<${bar}_final.total") or die "Can't open ${bar}_final.total\n";
		while ($line2=<IN2>){
		    chomp ($line2);
		    next unless ($line2);
		    ($seed, $count, @classes) = split ("\t", $line2);
		    ($seedno) = $seed=~/Seed ([0-9]+)$/;
		    $class = join ("_", @classes);
		    $hash{$bar}{$class}=$seedno;
		    $allclasshash{$class}++;
		}
		close (IN2);
		#record all the uclust groups (in FreClu parent seq names) per rdp group
		open (IN2, "<${bar}_final.group") or die "Can't open ${bar}_final.group\n";
                while ($line2=<IN2>){
                    chomp($line2);
                    next unless ($line2);
                    ($seedno, $freclu, $count) = split ("\t", $line2);
		    ($frecluname) = $freclu=~/^(.+)con_[0-9]+ reverse=/;
		    $hash2{$bar}{$seedno}{$frecluname}++;
                }
		close (IN2);
		#record all the concatenated sequences in each uclust group (names by FreClu parent seq name)
		open (IN2, "<${bar}_prechim.group") or die "Can't open ${bar}_prechim.group\n";
                while ($line2=<IN2>){
                    chomp($line2);
                    next unless ($line2);
                    ($seqname, $freclu, $conseq) = split ("\t", $line2);
		    $hash3{$bar}{$freclu}{$seqname}=$conseq;
                }
                close (IN2);
       	}
close (IN);

$find = "Root_ Bacteria_ Proteobacteria_ Betaproteobacteria_ Nitrosomonadales_ Nitrosomonadaceae_ Nitrosospira_ ";
#now, I can determine all the sequences that went into making one of the rdp groups
foreach $class (keys %allclasshash){
    next unless ($class eq $find);
    foreach $bar (keys %hash){
	$count=1;
	if ($hash{$bar}{$class}){
	    #there is one seedno with some number of FreClu names
	    foreach $frecluname (keys %{$hash2{$bar}{$hash{$bar}{$class}}}){
		foreach $seqname (keys %{$hash3{$bar}{$frecluname}}){
		    #record the total number of occurrances of this sequence in this library
		    $printhash{$bar}{$hash3{$bar}{$frecluname}{$seqname}}++;
		}
	    }
	    foreach $seq (keys %{$printhash{$bar}}){
		print ">${bthash{$bar}}_${count}_$printhash{$bar}{$seq}\n${seq}\n";
		$count++;
	    }
	}
    }
}
