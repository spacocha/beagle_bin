#!/usr/bin/env python

'''
script that loads metadata at every node of a phylogenetic tree and outputs:
- feature matrix for ML classification

here executed with the ibd athos data (454)

usage: 
python tree_work5.py test.tree test.mat

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
import numpy as np

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
patienttable = {}
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

def transpose(grid):
    return zip(*grid)

def removeBlankRows(grid):
    return [list(row) for row in grid if any(row)]

def contingency_adjust(table):
    """Fixes the chisq contingency table to remove any values that are 0 in all
    (R x C) table
    """
    table = np.asarray(table)
    if table.ndim != 2:
        raise ValueError("table must be a 2D array.")

    nr, nc = table.shape
    #print "NR: {0}, NC: {1}".format(nr,nc)
    grid=table
    newgrid=removeBlankRows(transpose(removeBlankRows(transpose(grid))))
    newgrid2 = np.asarray(newgrid)
    newnr,newnc=newgrid2.shape
    #print "NEWNR: {0}, NEWNC: {1}".format(newnr,newnc)
    total = newgrid2.sum()
    row_sum = newgrid2.sum(axis=1).reshape(-1,1)
    col_sum = newgrid2.sum(axis=0)
#    print "NEWNR: {0}, NEWNC: {1}, total:{2}, rowsum:{3}, colsum:{4}".format(newnr,newnc,total,row_sum,col_sum)
    if newnc !=1:
        (chi2,p,dof)=chisquare_contingency(newgrid)
    else:
        chi2=1
        p=1
        dof=0
        
    return chi2,p,dof
    
def chisquare_contingency(table):
    """Chi-square calculation for a contingency (R x C) table.
    
    This function computes the chi-square statistic and p-value of the
    data in the table.  The expected frequencies are computed based on
    the relative frequencies in the table.
    
    Parameters
    ----------
    table : array_like, 2D
    The contingency table, also known as the R x C table.
    
    Returns
    -------
    chisquare statistic : float
    The chisquare test statistic
    p : float
    The p-value of the test.
    """
    table = np.asarray(table)
    if table.ndim != 2:
        print table.ndim
        raise ValueError("table must be a 2D array.")
    
    # Create the table of expected frequencies.
    total = table.sum()
    row_sum = table.sum(axis=1).reshape(-1,1)
    col_sum = table.sum(axis=0)
    expected = row_sum * col_sum / float(total)
    
    # Since we are passing in 1D arrays of length table.size, the default
    # number of degrees of freedom is table.size-1.
    # For a contingency table, the actual number degrees of freedom is
    # (nr - 1)*(nc-1).  We use the ddof argument
    # of the chisquare function to adjust the default.
    nr, nc = table.shape
    dof = (nr - 1) * (nc - 1)
    
    chi2, p = scipy.stats.stats.chisquare(np.ravel(table), np.ravel(expected))
    p2=scipy.stats.stats.chisqprob(chi2, dof)
    return chi2, p2, dof

tree1 = dendropy.Tree.get_from_path(args[0], schema="newick", preserve_underscores=True)
outgroup_node = tree1.find_node_with_taxon_label("outgroup")
tree1.to_outgroup_position(outgroup_node)
nodes = tree1.nodes()
deletednodes={}
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
        if OTU == who and who != "outgroup":
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
                                if OTU2 != "outgroup" and OTU != "outgroup":
                                    if not done.has_key(OTU2):
                                        observed = np.array([matdata[OTU],matdata[OTU2]])
                                        (chi2,p,dof)=contingency_adjust(observed)
                                        (correl,p2)=scipy.stats.stats.pearsonr(matdata[OTU],matdata[OTU2])
                                        #                                    print "OTU, {0}, OTU2 {1}, p {2}, chi2 {3}, correl:{4}, p2:{5}".format(OTU,OTU2,p,chi2, correl, p2)
                                        if p < 0.0000001:
                                            print "Node delete: OTU {0} OTU2 {1} p: {2}".format(OTU,OTU2,p)
                                            deletednodes[par]=1
                                            loop=1
                                            while loop:
                                                par2=par.parent_node
                                                if par2:
                                                    deletednodes[par2]=1
                                                    par=par2
                                                else:
                                                    loop=0
                                        loop1=0
                    node=par
                    #goes with ch in childernone
                else:
                    loop1=0
                    #else goes with if par
                    
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
                if who !="outgroup":
                    groupdict[who]=group
                    print "{0},{1},{2},{3}".format(group,who,matdata[who],abunddict[who])
                
                        
