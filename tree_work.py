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

# reads in metadata and creates a data and an header dictionary
print "loading samples table..."
#metadata, metaheaders, metavalues = readMetaTable(table_handle)
headers = {}
start = 0
for line in table_handle:
    if not start:
        #first line gives the headers
        headers = line.rstrip('\n').split('\t')
        # fields is like an array
        start = 1
    else:
        fields = line.rstrip('\n').split('\t')
        print fields
        count=0
        for ind in headers:
            print "IND: {0}".format(ind)
            print "field {0}".format(fields[count])
            count2=count+1
            count=count2
            
        print 'This is a field: |{0}|'.format(fields[0])
        print 'This is another: |{0}|'.format(fields[1])

table_handle.close()
#headers contain all the samples that I need in keys
print "Done with table..."
print headers

#this is how I'll find the samples again after parsing the tree
#if 'ALGIERS-V1V3-rep01' in headers:
#    print "Found ALGIERS-V1V3-rep01..."

print "Parsing tree ..."

tree1 = dendropy.Tree.get_from_path(args[0], schema="newick", preserve_underscores=True)

print tree1

#get all the internal nodes on the tree
#these will be the features

newnodes = dendropy.dataobject.tree.Tree.internal_nodes(tree1)

#get a better naming system for nodes- since dendropy node names are meaningless
#use a leaf name for each child to define node
#then node will be identified as the last common ancestor of the two leaves

span1 = {}
span2 = {}
span1check = {}
span2check = {}
leafdict = {}

for nodeone in newnodes:
    span1done = 'False'
    print "Node"
    print nodeone
    childrenone = dendropy.dataobject.tree.Node.child_nodes(nodeone)
    print "Child"
    for ch in childrenone:
        #need a leaf name from each ch
        leafset = dendropy.dataobject.tree.Node.leaf_iter(ch)
        for leaf in leafset:
            itsaleaf =leaf
            print leaf
        who  = dendropy.dataobject.tree.Node.get_node_str(itsaleaf)
        if span1done is 'False':
            span1check[nodeone] = itsaleaf
            span1[nodeone]=who
            span1done = 'True'
        else:
            span2check[nodeone] = itsaleaf
            span2[nodeone] = who


print "Writing feature table"
debugm = open(dirname + 'debug.tab.metadata', 'w')
joined = 'Node_ID\tSpan'
for vals in headers:
    newstr = str(vals)
    print newstr
    newjoined = 'WHAT0{0}\tWHAT1{1}'.format(joined,newstr)
    joined = newjoined

debugm.write(str(joined))
debugm.write('\n')
                    
for printch in newnodes:
    metadatacount = {}
    print printch
    print "Span1..."
    print span1[printch]
    print "Span2..."
    print span2[printch]
    print "Confirm..."
    mrca = dendropy.dataobject.tree.Tree.ancestor(span1check[printch],span2check[printch])
    print mrca
    print "Leaf set.."
    leafset = dendropy.dataobject.tree.Node.leaf_iter(printch)
    total=0
    for leaf in leafset:
        who = dendropy.dataobject.tree.Node.get_node_str(leaf)
        distPattern = re.compile(r'_')
        alist = distPattern.split(who)
        if headers.has_key(alist[0]):
            total+=1
        if metadatacount.has_key(alist[0]):
            metadatacount[alist[0]]+=1
        else:
            metadatacount[alist[0]]=1

    freqdict={}
    for posdata in sorted(headers.iterkeys()):
        if metadatacount.has_key(posdata):
            freq = 1.*metadatacount[posdata]/total
            freqdict[posdata]=freq
        else:
            freqdict[posdata]=0

    joined = ''
    for vals in sorted(freqdict.iterkeys()):
        newstr = str(freqdict[vals])
        #print newstr
        newjoined = '{0}\t{1}'.format(joined,newstr)
        joined = newjoined

    printdebug ='{0}\t{1}|{2}{3}'.format(printch,span1[printch],span2[printch], joined)
    debugm.write(str(printdebug))
    debugm.write('\n')

debugm.close()
