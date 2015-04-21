#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: <input_file> <output>\n" unless (@ARGV);
	
chomp (@ARGV);
($file, $Rfile) = (@ARGV);

open (IN, "<${file}") or die "Can't open $file\n";
$first=1;
$lines=0;
while ($line=<IN>){
    if ($first){
	$first=();
	(@pieces)=split("\t", $line);
	$ncol =@pieces;
    } else {
	$lines++;
    }
}
close (IN);

$nr=$ncol-1;
$linesxlines=$lines*$lines;
open (FIS, ">${Rfile}.chi") or die "Can't open ${Rfile}.chi\n";
print FIS "x <- read.table(\"${file}\", header = TRUE)
output<-matrix(c(1:$linesxlines), nr=$lines)
for (test1 in 1:${lines}){
    for (test2 in 1:${lines}){
        alleles <- matrix(c(as.numeric(x[test1,2:$ncol]),as.numeric(x[test2,2:$ncol])),nr=$nr)
        newalleles <- alleles[rowSums(alleles) != 0, , drop=FALSE]
        htest2 <-chisq.test(newalleles)
        chip <-htest2\$p.value
        chiexp <-htest2\$expected
        vals1 <- sum(chiexp < 5)
        vals2 <- sum(chiexp > 0)
        if (vals2 > 0 ){
            ratio <- vals1/vals2
            if (ratio < 0.8){
                 htest3 <-chisq.test(newalleles, simulate.p.value = TRUE, B = 10000)
                 pvalue <- htest3\$pvalue
            } else {
                pvalue <- htest2\$pvalue
           }
        } else {
           pvalue <- NA
        }
        output[$test1,$test2]<-pvalue
    }
}
write.table(outpu,file=\"${Rfile}.pval\",sep=\"\t\",row.names=FALSE,col.names=FALSE)\n";


close (FIS);
