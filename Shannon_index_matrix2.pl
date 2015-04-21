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
			$h = 0;
			#calculate the KLdivergence
			#find a reference for this calculation!!!
			foreach $i (sort keys %{$mathash{$id}}){
			    #each is defined as the portion of the 
			    ($p) = $mathash{$id}{$i}/$totalhash{$id};
			    ($q) = $mathash{$oid}{$i}/$totalhash{$oid};
			    if (($q > 0) && ($p > 0)){
				$h+=($p*(log($p/$q)));
			    } else {
				$h+=0;
			    }
			}
			print "$id\t$oid\t$h\t";
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
