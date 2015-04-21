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

logging.basicConfig(level=logging.WARNING,
                    format="%(asctime)s - %(levelname)s - %(message)s")

def myxform(value):
    try:
        return float(value)
    except ValueError:
        return str(value)

#############################
###### parse input arguments

try:
    # opts gets all declared ones, args catches all the remaining ones
    opts, args = getopt.getopt(sys.argv[1:],
                               "d:p:t:u:c:",
                               ["data","pickledtree","thres","ucfile","colors"])
except getopt.GetoptError, err:
    sys.exit(2)

cpsetreshold = None
collapse = False
readtree = True
useclusterinfo = False
colorsprovided = False

#input files are in args.. 
if len(args) > 0:
    tree_handle = open(args[0],'r')
    tree_filename = args[0].rstrip(".tree")
    #pickledump_handle = open(args[0]+".pickled",'w')
    table_handle = open(args[1],'r')

for op, ar in opts:
    if op in ("-h", "--help"):
        usage()
        sys.exit()
    elif op in ("-t", "--thres"):
        collapse = True
        cpsethreshold = float(ar)
    elif op in ("-p", "--pickledtree"):
        readtree = False
        pickle_handle = open(ar,'r')
        phylotree = pickle.load(pickle_handle)
    elif op in ("-d", "--data"):
        table_handle = open(ar,'r')
    elif op in ("-u", "--ucfile"):
        ucfileh = open(ar,'r')
        useclusterinfo = True
    elif op in ("-c","--colors"):
        config = ConfigParser.ConfigParser()
        config.optionxform = myxform #keep case sensitive
        config.read(ar)
        colorsprovided = True
    else:
        assert False, "unhandled option"


#####################################
####### make some space #############

# save in folders, which are dated & progressively numbered
d = date.today()
d_s = d.strftime("%y%m%d")
dirnum = 1
while os.path.isdir('./' + d_s + '_parsed_' + tree_filename + '_' + str(dirnum) + '/'):
    dirnum += 1
dirname = './' + d_s + '_parsed_' + tree_filename + '_' + str(dirnum) + '/'
os.mkdir(dirname)


####################################
####### read metadata ##############


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
        group=group+1
        if not deletednodes.has_key(ch):
            leafset = dendropy.dataobject.tree.Node.leaf_iter(ch)
            for leaf in leafset:
                itsaleaf =leaf
                who  = dendropy.dataobject.tree.Node.get_node_str(itsaleaf)
                print "{0},{1}".format(group,who)
                
                        
