#! /usr/bin/perl -w
#
#	Use this program as part of the eOTU pipeline
#

	die "Input the following:
full_list- file name of the complete OTU list
line_no- the line from the OTU list that will be evalulated
fasta- full fasta file with sequences and names that match those in the list
mat- full mat file
filter_number- the number of times the sequence must be seen in order to keep it
output_prefix- what the output files will begin with
comb_reps_file- file with two columns. The first column is the unique lib name, the second is the combreps lib name 
(multiple unique libs will be merged if they have the same combreps lib name)

Usage: full_list line_no fasta mat output_prefix\n" unless (@ARGV);
	
	chomp (@ARGV);
	($full_list, $lineno,  $fullfasta, $fullmat, $output) = (@ARGV);
die "list_through_filter_from_mat.pl: Please follow the command line arguments\n" unless ($output);

chomp ($full_list);
chomp ($lineno);
chomp ($fullfasta);
chomp ($fullmat);
chomp ($output);

#read in the list file and capture the OTU on the right line according to the lineno
$curline=0;
open (IN, "<${full_list}") or die "Can't open ${full_list}\n";
while ($line1 = <IN>){
    chomp ($line1);
    $curline++;
    next unless ($curline == $lineno);
    (@pieces) = split ("\t", $line1);
    foreach $piece (@pieces){
	$otuhash{$piece}++;
    }
}
close (IN);

die "list_through_filter_from_mat.pl:Missing OTUhash\n" unless (%otuhash);
#reminder info: %otuhash contains all of the OTUs that we want to evaluate
#nothing else should be retained

#change the line breaks to > for fasta format
$/ = ">";

#read in the full fasta file
open (IN, "<$fullfasta") or die "Can't open $fullfasta\n";
open (FA, ">${output}.fa") or die "Can't open ${output}.fa\n";

while ($line1 = <IN>){	
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    #filter out all of the other entries
    next unless ($otuhash{$info});
print FA ">$line1\n" if ($otuhash{$info});
    #merge the sequences from different lines
}

close (IN);

#change back the line breaks
    $/="\n";

#open in the full trans file
(@headers)=();
open (IN, "<$fullmat" ) or die "Can't open $fullmat\n";
open (MAT, ">${output}.mat") or die "Can't open ${output}.mat\n";
while ($line =<IN>){
chomp ($line);
    next unless ($line);
    ($OTU, @pieces)=split ("\t", $line);
    if (@headers){
	if ($otuhash{$OTU}){
	    print MAT "$line\n";
	}
    } else {
	(@headers)=@pieces;
	print MAT "$line\n";
    }
}
close (IN);

