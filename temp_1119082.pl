#! /usr/bin/perl -w
#
#

	die "Usage:  <file> > redirect\n" unless (@ARGV);
	($transfile) = (@ARGV);
	chomp ($transfile);
	die "Please follow command line args\n" unless ($transfile);
	open (IN, "<$transfile") or die "Can't open $transfile\n";
	while ($line=<IN>){
		chomp ($line);
		($indcomp, $total, @pop)=split ("\t", $line);
		($comp, $ind, $sea) = $indcomp=~/^(..)(.)(.)$/;
		if ($sea eq "F"){
			$new1=$pop[0]+$pop[1]+$pop[4]+$pop[5]+$pop[6]+$pop[11]+$pop[17];
			$new2=$pop[9]+$pop[14]+$pop[16];
			$new3=$pop[2]+$pop[15];
			$pop12=$pop[3];
			$pop17=$pop[8];
			$pop4=$pop[12];
			$pop5=$pop[13];
			$other=$total-$new1-$new2-$new3-$pop12-$pop17-$pop4-$pop5;
			$hash{$comp}{"1"}{$ind}=($new1/$total);
			$hash{$comp}{"18"}{$ind}=($new2/$total);
			$hash{$comp}{"11"}{$ind}=($new3/$total);
			$hash{$comp}{"12"}{$ind}=($pop12/$total);
			$hash{$comp}{"17"}{$ind}=($pop17/$total);
			$hash{$comp}{"4"}{$ind}=($pop4/$total);
			$hash{$comp}{"5"}{$ind}=($pop5/$total);
			$hash{$comp}{"other"}{$ind}=($other/$total);
			$totalhash{$comp}{$ind}=$total;
		}
	}
	close (IN);

foreach $comp (sort keys %hash){
	foreach $pop (sort keys %{$hash{$comp}}){
		open (SET, ">/file.set") or die "Can't open /file.set\n";	
		open (DAT, ">/file.dat") or die "Can't open /file.dat\n";	
		$total=0;
		$totalave=();
		%hash1=();
		$chisq=();
		foreach $ind (sort keys %{$hash{$comp}{$pop}}){
			$totalave+=$totalhash{$comp}{$ind};
			$total++;
			$hash1{$hash{$comp}{$pop}{$ind}}++;
		}
		$aven=$totalave/$total;
		print SET "1000\t$total\n";
		close (SET);
		stdev ();
		$sampave= $average;
		#what is the mean?- $average
		#what is the var?- $var;
		if ($sampave){
			@totalhasharray=();
			foreach $ind (sort keys %{$hash{$comp}{$pop}}){
				print DAT "$totalhash{$comp}{$ind}\t$sampave\n";
				push (@totalhasharray,$totalhash{$comp}{$ind});
				$abc = $hash{$comp}{$pop}{$ind}- ($totalhash{$comp}{$ind}*$sampave);
				$abcsq = $abc*$abc;
				$def = $totalhash{$comp}{$ind}*($sampave)*(1-$sampave);
				$ghi = $abcsq/$def;
				$chisq+=$ghi;
			}
			close (DAT);
			#generate 1000 vectors with the total number of samples from the comp
			system ("R --slave --vanilla < /Applications/random_binomial2\n");		
			#read in the random data
			open (IN2, "</output.tab") or die "Can't open /output.tab\n";
			$lineno=0;
			while ($line2=<IN2>){
				next unless ($line2);
				(@values) = split("\t", $line2);
				#@values is like the number of strains from each pop in the binomial sample
				#calc the chisq value for the random trial
				$rchisq=0;
				$rghi=0;
				$rabc=0;
				$rdef=0;
				$indexval=0;
				%hash1 =();
				$totalave=0;
				$total=0;
				foreach $number (@values){
					$totalave+=$totalhasharray[$indexval];
		                        $total++;
					$put=$number/$totalhasharray[$indexval];
                		        $hash1{$put}++;
					$indexval++;
				}
				stdev ();
				$raverage=$average;
				if ($raverage || $raverage==1){
					$indexval=0;
					foreach $number (@values){
						die unless ($number=~/[0-9]+/);
						$rabc= $number - ($totalhasharray[$indexval]*$raverage);
						$rabcsq=$rabc*$rabc;
						$rdef=$totalhasharray[$indexval]*($raverage)*(1-$raverage);
						$rghi=$rabcsq/$rdef;
						$indexval++;
						$rchisq+=$rghi;
					}
				} else {
					$rchisq=0;
				}			
				$lineno++;
				$results{$lineno}=$rchisq;	
			}
			close (IN2);
			@newres=0;
			foreach $resval (sort {$results{$a}<=>$results{$b}} keys %results){
				push (@newres, $results{$resval});
			}
			$alpha0one=$newres[989];
			$alpha00one=$newres[999];
			print "$comp\t$pop\t";
			foreach $ind (sort keys %{$hash{$comp}{$pop}}){
				print "$hash{$comp}{$pop}{$ind}\t$totalhash{$comp}{$ind}\t";
			}
			print "$aven\t$average\t$chisq\t$alpha0one\t$alpha00one\n";
			system("rm /file.set");
			system("rm /file.dat");
		} else {
			print "$comp\t$pop\t";
			foreach $ind (sort keys %{$hash{$comp}{$pop}}){
				print "$hash{$comp}{$pop}{$ind}\t$totalhash{$comp}{$ind}\t";
			}
			print "$aven\t$average\t0\t0\t0\n";
		}
	}
}
						
sub stdev {
        
        #input a hash with the values to be averaged and stdev'd
        #from Biometry Sokal et al (?)

        return $std = 0 if ($total == 0);               #can not find stdev if there are no values
        $sum =0;                                        #blank this value
	$total2=0;
        foreach $value (keys %hash1){                    #find the sum of all values
		$i=0;
		until ($i>=$hash1{$value}){
	                $sum+=$value;
			$i++;
			$total2++;
		}
        }

        $average = $sum/$total2;                         #calculate the mean or average
        
        $ysq = 0;                                       #clear values
        $ysum = 0;

        foreach $value (keys %hash1){                    #for each find the square of the difference from the mean
		$i=0;
		until ($i>=$hash1{$value}){
	                $y = $value - $average;
        	        $ysq = $y*$y;
                	$ysum+=$ysq;                            #sum all squared values
			$i++;
		}
        }
        
        $std = sqrt($ysum/($total2 - 1));                #find the square root of the squared sum divided by total -1
        $var=$std**2;
}
