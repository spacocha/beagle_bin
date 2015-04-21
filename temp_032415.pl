#! /usr/bin/perl -w

die "Usage: file > redirect output\n" unless (@ARGV);
($file) = (@ARGV);
chomp ($file);

open (IN1, "<$file" ) or die "Can't open $file\n";
while ($line1 =<IN1>){
    chomp ($line1);
    next unless ($line1);
    ($OTU, $RA)=split ("\t", $line1);
    $hash{$OTU}=$RA;

}
close (IN1);
foreach $OTU (sort {$hash{$b} <=> $hash{$a}} keys %hash){
    next if ($OTU=~/Actinobacillus_pleuropneumoniae_sv_7_AP76/ || $OTU=~/Arthrospira_platensis_str_Paraca/ || $OTU=~/Beggiatoa_sp_SS/ || $OTU=~/Bifidobacterium_longum_infantis_CCUG_52486/ || $OTU=~/Blautia_hydrogenotrophicus_S5a33_DSM_10507/ || $OTU=~/Borrelia_burgdorferi_94a/ || $OTU=~/Buchnera_aphidicola_Bp/ || $OTU=~/Candidatus_Sulcia_muelleri_GWSS/ || $OTU=~/Chlamydia_trachomatis_70/ || $OTU=~/Clostridium_difficile_CD196/ || $OTU=~/Clostridium_difficile_R20291/ || $OTU=~/Clostridium_sporogenes_ATCC_15579/ || $OTU=~/Coprococcus_eutactus_ATCC_27759/ || $OTU=~/Cyanothece_sp_ATCC_51142/ || $OTU=~/Desulfovibrio_desulfuricans_G20/ || $OTU=~/Ehrlichia_ruminantium_Welgevonden_CIRAD/ || $OTU=~/Enterococcus_faecium_1_141_733/ || $OTU=~/Enterococcus_faecium_C68/ || $OTU=~/Enterococcus_faecium_TC_6/ || $OTU=~/Escherichia_coli_SE11/ || $OTU=~/Eubacterium_dolichum_DSM_3991/ || $OTU=~/Fusobacterium_nucleatum_nucleatum_ATCC_25586/ || $OTU=~/Geobacillus_sp_C56_T3/ || $OTU=~/Gluconacetobacter_hansenii_ATCC_23769/ || $OTU=~/Granulicatella_elegans_ATCC_700633/ || $OTU=~/Hahella_chejuensis_KCTC_2396/ || $OTU=~/Holdemania_filiformis_VPI_J1_31B_1_DSM_12042/ || $OTU=~/Methylovorus_sp_SIP3_4/ || $OTU=~/Microscilla_marina_ATCC_23134/ || $OTU=~/Mobiluncus_mulieris_ATCC_35243/ || $OTU=~/Mycobacterium_bovis_AF2122_97/ || $OTU=~/Neisseria_gonorrhoeae_35_02/ || $OTU=~/Neptuniibacter_caesariensis/ || $OTU=~/Oxalobacter_formigenes_OXCC13/ || $OTU=~/Pectobacterium_carotovorum_brasiliensis_PBR1692/ || $OTU=~/Photobacterium_profundum_3TCK/ || $OTU=~/Photobacterium_angustum_S14/ || $OTU=~/Pseudomonas_syringae_pv_syringae_B728a/ || $OTU=~/Rothia_dentocariosa_ATCC_17931/ || $OTU=~/Staphylococcus_aureus_A9754/ || $OTU=~/Staphylococcus_aureus_aureus_MRSA_USA300_TCH1516/ || $OTU=~/Staphylococcus_aureus_subsp_aureus_M809/ || $OTU=~/Synechococcus_sp_CC9311/ || $OTU=~/Thermanaerovibrio_acidaminovorans_DSM_6589/ || $OTU=~/Thermobifida_fusca_YX/ || $OTU=~/Yersinia_mollaretii_ATCC_43969/);
    next if ($OTU=~/^[0-9]/);
    next if ($printed{$hash{$OTU}});
    print "${OTU}2\t$hash{$OTU}\n" if ($hash{$OTU});
    $printed{$hash{$OTU}}++;
}
