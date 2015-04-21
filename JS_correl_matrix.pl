#! /usr/bin/perl -w
#
#

	die "Usage:  matrix Rfile > redirect\n" unless (@ARGV);
	($mine, $Rfile) = (@ARGV);
	chomp ($mine);
	die "Please follow command line args\n" unless ($mine);
	open (IN, "<$mine") or die "Can't open $mine\n";
	while ($line=<IN>){
		chomp ($line);
		next unless ($line);
		(@pieces) = split ("\t", $line);
		if (@header){
			#this is not the first line
			$i=1;
			$j = @pieces;
			until ($i >= $j){
			    unless ($header[$i] eq "Lin"){
				$matbarhash{$header[$i]}++;
				if ($pieces[$i]){
				    $mathash{$pieces[0]}{$header[$i]}=$pieces[$i];
				} else {
				    #add some small amount to each 
				    $mathash{$pieces[0]}{$header[$i]}=0.00001;
				}
				$totalhash{$pieces[0]}+=$pieces[$i] unless ($header[$i] eq "Lin");
			    }
			    $i++;
			}
		} else {
			(@header) = (@pieces);
		}
		
	}	
	close (IN);
	foreach $id (sort {$totalhash{$b} <=> $totalhash{$a}} keys %totalhash){
		next unless ($id);
		foreach $oid (sort keys %mathash){
			next unless ($oid);
			next if ($done{$oid}{$id});
			$done{$oid}{$id}++;
			$done{$id}{$oid}++;
			$KL1=0;
			$KL2=0;
			$newKL=0;
			#calculate the KLdivergence
			#find a reference for this calculation!!!
			#I need to use both
			foreach $header (sort keys %matbarhash){
			    #each is defined as the portion of the 
			    if ($mathash{$id}{$header}){
				($p) = $mathash{$id}{$header}/$totalhash{$id};
			    } else {
				$p=0;
			    }
			    if ($mathash{$oid}{$header}){
				($q) = $mathash{$oid}{$header}/$totalhash{$oid};
			    } else {
				$q=0;
			    }
			    if (($q > 0) && ($p > 0)){
				#first make the KL of x,(x+y)/2
				$KL1+=($p*(log($p/(($p+$q)/2))));
				$KL2+=($q*(log($q/(($q+$p)/2))));
			    }
			}
			$newKL=($KL1 + $KL2)/2;
			print "$id\t$oid\t$newKL\t";
			$string=();
			$totalnolib=();
			foreach $bar (sort keys %matbarhash){
			    #don't print, but pass something to R
			    $mathash{$oid}{$bar} = 0 unless ($mathash{$oid}{$bar});
			    $mathash{$id}{$bar} =0 unless ($mathash{$id}{$bar});
			    if ($mathash{$oid}{$bar} || $mathash{$id}{$bar}){
				if ($string){
				    $string="$string"."$mathash{$oid}{$bar}\t$mathash{$id}{$bar}\n";
				} else {
				    $string="$mathash{$oid}{$bar}\t$mathash{$id}{$bar}\n";
				}
				$totalnolib++ if ($mathash{$oid}{$bar} || $mathash{$id}{$bar});
			    }
			}
			if ($totalnolib ==1){
			    $correl="NA";
			} else {
			    system ("rm ${Rfile}.corv\n") if (-e "${Rfile}.corv");
			    #run chisq and fishers
			    open (INPUT, ">${Rfile}.in") or die "Can't open ${Rfile}.in\n";
			    print INPUT "$string\n";
			    close (INPUT);
			    open (FIS, ">${Rfile}.cor") or die "Can't open ${Rfile}.cor\n";
			    print FIS "x <- read.table(\"${Rfile}.in\", header = FALSE)                                                                                        
a<-x[1:${totalnolib},1]                                                                                               
b<-x[1:${totalnolib},2]                                                                                                                                                         
j<-cor(a,b)                                                                               
print(j)
write.table(j,file=\"${Rfile}.corv\",sep=\"\t\",row.names=FALSE,col.names=FALSE)\n";
			    close (FIS);
			    #I'm only combining if they are highly correlated
			    system ("R --slave --vanilla --silent < ${Rfile}.cor >> ${Rfile}.err");
			    #whats the corelation?
			    if (-e "${Rfile}.corv"){
				$correl=();
				open (RES, "<${Rfile}.corv") or die "Can't open ${Rfile}.corv\n";
				while ($Rline=<RES>){
				    chomp ($Rline);
				    next unless ($Rline);
				    ($correl)=$Rline=~/^(.+)$/;
				}
				close (RES);
			    } else {
				die "${Rfile}.corv not available\n";
			    }
			}
			print "$correl\n";
		    }
	    }
