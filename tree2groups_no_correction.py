#!/usr/bin/env python

'''
script that loads metadata at every node of a phylogenetic tree and outputs:
- feature matrix for ML classification

here executed with the ibd athos data (454)

usage: 
extract_features_051110.py -d sampledata.txt rooted.tree

'''
import sys
import getopt
import pickle
import os
from datetime import date
import logging
import ConfigParser
import random
import dendropy
import operator
import scipy

from scipy import stats
from dendropy import Tree, Node, treemanip


#############################
###### parse input arguments

try:
    # opts gets all declared ones, args catches all the remaining ones
    opts, args = getopt.getopt(sys.argv[1:],
                               "d:p:t:u:c:",
                               ["data","pickledtree","thres","ucfile","colors"])
except getopt.GetoptError, err:
    sys.exit(2)

#input files are in args.. 
if len(args) > 0:
    tree_handle = open(args[0],'r')
    tree_filename = args[0].rstrip(".tree")
    mathandle= open(args[1],'r')

####### read tree ##############


tree1 = dendropy.Tree.get_from_path(args[0], schema="newick", preserve_underscores=True)

allnodes = tree1.nodes()
#what are the branch lengths on the tree?
#find the longest branch


nodelen={}
for node in allnodes:
    len = node.edge_length
    nodelen[node]=len

deletednodes={}
total=0
for node in sorted(nodelen.iterkeys(), reverse=True):
    if nodelen[node] > 0.1:
        #get all parent nodes
        par = node.parent_node
        loop=1
        while loop:
            par=node.parent_node
            if par:
                if not deletednodes.has_key(par):
                    deletednodes[par]=1
                node=par
            else:
                loop=0


headers = {}
matdata ={}
abunddict={}
start=0
one=1
for line in mathandle:
    if not start:
        #first line gives the headers
        headers = line.rstrip('\n').split('\t')
        start=1
    else:
        fields = line.rstrip('\n').split('\t')
        count=0
        abund=0
        OTU=fields[0]
        data=fields[1:]
        data = [float(entry) for entry in data]
        matdata[OTU]=data
        abund=sum(data)
        abunddict[OTU]=abund
        #print "OTU: {0} ABUND:{1}".format(OTU,abund)

mathandle.close()

pvaluedict={
    "ID0000014P": 1,
    "ID0000012P" : 1,
    "ID0000016P" : 0,
    "ID0000017P": 0,
    "ID0000013P" : 1,
    "ID0000007P" : 1,
    "ID0000015P": 0,
    "ID0000008P" : 0,
    "ID0000006P" : 0
    }

nodes = tree1.nodes()
leafset=tree1.leaf_nodes()
for OTU in sorted(abunddict, key=abunddict.__getitem__, reverse=True):
    #start with the most abundant OTU and get parent then children
    #if any of the children of the parent node is statistically significantly different, delete node
    #go up from the parent until a deleted node is created then stop
    #which node is associated with this OTU name?
    #Find a function that finds the node associated with this ID
    for leaf in leafset:
        #find the index for OTU
        who  = dendropy.dataobject.tree.Node.get_node_str(leaf)
        if OTU == who:
            #get OTUs parent node
            done={}
            loop1=1
            node=leaf
            while loop1:
                par = node.parent_node
                #there are two children for the parent node
                #check to see if the leaves under this parent are
                if par:
                    childrenone = dendropy.dataobject.tree.Node.child_nodes(par)
                    for ch in childrenone:
                        leafset2 = dendropy.dataobject.tree.Node.leaf_iter(ch)
                        for leaf in leafset2:
                            OTU2  = dendropy.dataobject.tree.Node.get_node_str(leaf)
                            if not OTU == OTU2:
                                if not done.has_key(OTU2):
                                    css,pvalue=scipy.stats.chisquare(matdata[OTU])
                                    #print "NOT-MAT1: {0} {1}, MAT2:{2} {3} PVALUE:{4}".format(matdata[OTU],OTU,matdata[OTU2],OTU2,pvalue)
                                    done[OTU2]=1
                                    #print "Pvalue:{0} OTU2:{1}".format(pvaluedict[OTU2],OTU2)
                                    if pvaluedict[OTU2] < 0.001:
                                        if not deletednodes.has_key(par):
                                            deletednodes[par]=1
                                        loop=1
                                        while loop:
                                            par2=par.parent_node
                                            if par2:
                                                if not deletednodes.has_key(par2):
                                                    deletednodes[par2]=1
                                                par=par2
                                            else:
                                                loop=0
                                    loop1=0
                    node=par
                else:
                    loop1=0
                    
group=0
groupdict={}
for par in deletednodes.iterkeys():
    childrenone = dendropy.dataobject.tree.Node.child_nodes(par)
    #print "Child"
    for ch in childrenone:
        if not deletednodes.has_key(ch):
            group=group+1
            leafset = dendropy.dataobject.tree.Node.leaf_iter(ch)
            for leaf in leafset:
                itsaleaf =leaf
                who  = dendropy.dataobject.tree.Node.get_node_str(itsaleaf)
                print "{0},{1},{2},{3}".format(group,who,matdata[who],abunddict[who])
                
                        
