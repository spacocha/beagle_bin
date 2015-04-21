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

####### read tree ##############
headers = {}
distdata ={}
start=0
one=1
for line in tree_handle:
    if not start:
        #first line gives the headers
        headers = line.rstrip('\n').split('\t')
        start=1
    else:
        fields = line.rstrip('\n').split('\t')
        count=0
        abund=0
        OTU=fields[0]
        OTU2=fields[1]
        dist=fields[2]
        float(dist)
        distdata[OTU]={}
        distdata[OTU][OTU2]=dist
        
tree_handle.close()
        
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

for OTU in sorted(abunddict, key=abunddict.__getitem__, reverse=True):
    #start with the most abundant OTU and get parent then children
    #if any of the children of the parent node is statistically significantly different, delete node
    #go up from the parent until a deleted node is created then stop
    #which node is associated with this OTU name?
    #Find a function that finds the node associated with this ID
    for OTU2 in sorted(distdict[OTU], key=distdict[OTU].__getitem__, reverse=True):
        print "OTU: {0}, distdict:{1}".format(OTU,distdata[OTU])
        for OTU2 in sorted(distdata[OTU][OTU2], key=distdata[OTU][OTU2].__getitem__, reverse=False):
            if OTU2 != "outgroup":
                print "OTU1, {0}: OTU2,{1}: dist{2}".format(OTU,OTU2,distdata[OTU][OTU2])
                sum1=sum(matdata[OTU])
                sum2=sum(matdata[OTU2])
                if sum1 > 1 and sum2 > 1:
                    print "SUM1: {0}, SUM2, {1}".format(sum1,sum2)
                    observed = np.array([matdata[OTU],matdata[OTU2]])
                    (chi2,p,dof)=contingency_adjust(observed)
                    (correl,p2)=scipy.stats.stats.pearsonr(matdata[OTU],matdata[OTU2])
                    #                                    print "OTU, {0}, OTU2 {1}, p {2}, chi2 {3}, correl:{4}, p2:{5}".format(OTU,OTU2,p,chi2, correl, p2)
                    if p < 0.0000001:
                        print "Node delete: OTU {0} OTU2 {1} p: {2}, dof:{3}, correl:{4}".format(OTU,OTU2,p,dof,correl)
            
