#! /usr/bin/perl
#
#

	die "Usage: trans uniquefasta fullfasta list output\n" unless (@ARGV);
	($trans, $uniquefasta, $fullfasta, $list, $output) = (@ARGV);

	die "Please follow command line args\n" unless ($list);
chomp ($trans);
chomp ($list);
chomp ($uniquefasta);
chomp ($fullfasta);
chomp ($output);

$/=">";
open (IN1, "<$uniquefasta") or die "Can't open $uniquefasta\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($name, @seqs)=split ("\n", $line1);
    ($sequence)=join ("", @seqs);
    $uniseqhash{$sequence}=$name;
    $seqhash{$name}=$sequence;
}
close (IN1);

open (TRANS, ">${output}.trans") or die "Can't open ${output}.trans\n";
open (FA, ">${output}.fa") or die"Can't open ${output}.fa\n";
open (LIST, ">${output}.list") or die"Can't open ${output}.list\n";

open (IN1, "<$fullfasta") or die "Can't open $fullfasta\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($name, @seqs)=split ("\n", $line1);
    ($sequence)=join ("", @seqs);
    if ($uniseqhash{$sequence}){
	$hash{$name}=$uniseqhash{$sequence};
    } else {
	if ($mothurunique{$sequence}){
	    #it's already got a name, just make the translation
	    print TRANS "$name\t$mothurunique{$sequence}\n";
	    $hash{$name}=$mothurunique{$sequence};
	} else {
	    #make a new name
	    $count++;
	    $newname="M${count}R";
	    #record the seqeunce
	    $mothurunique{$sequence}=$newname;
	    $seqhash{$newname}=$sequence;
	    $hash{$name}=$newname;
	    print FA ">$newname\n$sequence\n";
	    print TRANS "$name\t$newname\n";
	}
    }
}
close (IN1);

$/="\n";

open (IN1, "<$trans") or die "Can't open $trans\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($name, $unique)=split ("\t", $line1);
    ($shrt)=$name=~/^.+? (.+\/1) /;
    $hash{$shrt}=$unique;
}
close (IN1);

open (IN1, "<$list") or die "Can't open $list\n";
while ($line1=<IN1>){
    chomp ($line1);
    next unless ($line1);
    (@seqs)=split ("\t", $line1);
    $OTUc++;
    (@piecesc) = split ("", $OTUc);
    $these = @piecesc;
    $zerono = 3 - $these;
    $zerolet = "0";
    $zeros = $zerolet x $zerono;
    $OTUn="Otu${zeros}${OTUc}";
    print LIST "$OTUn";

    foreach $seq (@seqs){
	if ($hash{$seq}){
	    if ($done{$hash{$seq}}){
		die "same unique in different id $id unique $hash{$seq} recorded id $done{$hash{$seq}} name $seq\n" unless ($OTUn eq $done{$hash{$seq}});;
		$abundhash{$OTUn}{$hash{$seq}}++;
	    } else {
		$abundhash{$OTUn}{$hash{$seq}}++;
		print LIST "\t$hash{$seq}";
		$done{$hash{$seq}}=$OTUn;
	    }
	}else {
	    die "Missing translation $seq\n";
	}
    }
    print LIST "\n";
}
close (IN1);
open (OTUFA, ">${output}.otu.rep.fa") or die "Can't open ${output}.otu.rep.fa\n";
foreach $OTU (sort keys %abundhash){
    foreach $rep (sort {$abundhash{$OTU}{$b} <=> $abundhash{$OTU}{$a}} keys %{$abundhash{$OTU}}){
	print OTUFA ">$OTU\n$seqhash{$rep}\n";
	last;
    }
}

close (OTUFA);
