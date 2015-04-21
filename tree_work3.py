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
                deletednodes[par]=1
                node=par
            else:
                loop=0


group=0
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
                print "{0},{1}".format(group,who)
                
                        
