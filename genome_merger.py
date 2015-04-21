#!/usr/bin/env python

''' Genome merger: merges incomplete genomes from genbank files into one genome for simulation sequences

'''
#needed to parse sequence files and alignments
#record version information here
version="Genome merger 0.0.1"

import Bio
from Bio import SeqIO
import argparse

#not sure if I need any of these

#Create custom defs
if __name__ == '__main__':
   parser = argparse.ArgumentParser(description='Create OTUs using ecological and genetic information (DBC version 2.0)')
   parser.add_argument('-i', '--inputfile',  help='input file name')
   parser.add_argument('-o', '--outputprefix', help='output prefix')
   args = parser.parse_args()

   #Open the files to gather information
   #list file                                                                                                                                                                                      
   handle = open(args.inputfile, "rU")
   for record in SeqIO.parse(handle, "genbank") :
      for feat in record.features:
         print feat
   handle.close()
      
