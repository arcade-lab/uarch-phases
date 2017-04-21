#############################################################################
##  This file is part of a signal tracing utility for the LEON3 processor 
##  Copyright (C) 2017, ARCADE Lab @ Columbia University
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##  
##  You should have received a copy of the GNU General Public License
##  along with this program. If not, see <http://www.gnu.org/licenses/>. 
##
#############################################################################
## File:        pcprocess.py
## Author:      Van Bui - ARCADE @ Columbia University
## Description: Processes raw processor signal data (pc data only) and 
##              generates phase stats for IWS and BBV 
#############################################################################

#!/usr/bin/env python

import numpy as np
import sys
import scipy.spatial.distance as scp

def chunker(iterable, chunksize):
    return zip(*[iter(iterable)]*chunksize)

def get_counts(cs):
    chunkdat = chunker(cs,2)
    d = {}
    for c in chunkdat:
        id = int(c[0],16)
        val = int(c[1],16)
        d[id]=val

    if '' in d:
        del d['']

    return d

def read_data(fname):
    fdat = file(fname,'r')
    idmap = {}
    mapdat = []
    trace = []
    for line in fdat:
        if 'samples' in line:
            words = line.split()
            numsamples =  int(words[3])
        if 'START' in line:
            words = line.split()
            tracesamples = 0
            start=0
            for w in words:
                if start == 1 and w != 'DONE':
                  mapdat.append(w)  
                if w == 'dict':
                    start=1
                if w != 'START' and start != 1:
                    trace.append(int(w,16))
                if w == 'DONE':
                    break
            
    d = get_counts(mapdat)

    fdat.close()

    if len(trace)!=numsamples:
        print fname, 'incorrect number of samples'

    return d,trace

def formbbv(chunk, mapdat):
    
    signature = {}
    for k,v in mapdat.iteritems():
        if v==1:
            signature[k]=0
            
    insts = []

    if len(chunk)!=1:  # can not form a bbv with a chunk size of 1
        for l in chunk:
            insts.append(l)
            if mapdat[l] == 1:
                instcount = len(set(insts))
                signature[l]+=instcount
                insts = []

    bbvsum = float(sum(signature.values()))
    
    normbbv = []

    if bbvsum == 0:
        normbbv = [0.0 for b in range(0,len(signature.keys()))]
    else:
        normbbv = [signature[b]/bbvsum for b in sorted(signature.keys())]

    return normbbv

def working_set_dist(sig1,chunk,size):

    sig2 = [0 for i in range(0,size)]

    for c in chunk:
        sig2[c]=1

    s1ors2 = [s1 or s2 for s1,s2 in zip(sig1,sig2)]
    s1xors2 = [s1 ^ s2 for s1,s2 in zip(sig1,sig2)]
    diff = s1xors2.count(1)/float(s1ors2.count(1))

    return diff,sig2

def get_phase_stats(phase,cycles,anycount,setphase):

    pcount = {}
    sigstd = []

    for s in setphase:
        val = np.std(s)
        sigstd.append(val)

    if len(phase) > 0:
        for i in set(phase):
            pcount[i] = phase.count(i)

        stats = str(min(phase))+' '+str(np.mean(phase))+' '+str(max(phase))+' '+str(np.std(phase))+' '+str(len(phase))+' '+str(sum(phase))+' '+str(cycles)+' '+str(anycount)+' '+str(len(setphase))+' '+str(np.mean(sigstd))+' '+str(np.std(sigstd))

        for k,v in pcount.iteritems():
            stats = stats + ' '+str(k)+ ' '+str(v)
    else:
        stats = '0 0 0 0 0 0'+' '+str(cycles)+' '+str(anycount)+' 0 0 0'

    return stats

def gen_data(brdat,mapdat,tracedat,interval,thresholds1,thresholds2):

    cycles = float(len(tracedat))
    
    singlephase = [int(cycles)]

    chunkdat = chunker(tracedat,interval)

    numchunks = len(chunkdat)

    print numchunks, int(cycles), len(tracedat),interval    

    rem = []
    if (numchunks*interval) != cycles:
        endind = numchunks*interval
        for i in range(endind, int(cycles)):
            rem.append(tracedat[i])


    last = chunkdat.pop(0)
    uniq = len(mapdat)

    sig1 = [0 for i in range(0,uniq)]
    
    for l in last:
        sig1[l]=1

    numthresholds1 = len(thresholds1)
    numthresholds2 = len(thresholds2)

    numbranches = 0
    for k,v in brdat.iteritems():
        if v==1:
            numbranches+=1

    interval_count_iws = [1 for i in range(0,numthresholds1)] # should this be a dictionary?
    iwsphases = {}
    iwsstats = {}
    for i in range(0,numthresholds1):
        iwsphases[i] = []

    lastbbv = formbbv(last,brdat)
    interval_count_bbv = [1 for i in range(0, numthresholds2)]
    bbvphases = {}
    bbvstats = {}
    
    setiws = []
    setbbv = []

    setiws.append(sig1)
    setbbv.append(lastbbv)

    for i in range(0,numthresholds2):
        bbvphases[i] = []    

    for chunk in chunkdat:
        diff,sig2 = working_set_dist(sig1,chunk,uniq)
        sig1 = sig2
        if sig1 not in setiws:
            setiws.append(sig2)


        for i in range(0,numthresholds1):
            
            if diff <= thresholds1[i]:
                interval_count_iws[i]+=1
            else:
                if interval_count_iws[i] > 1:
                    iwsphases[i].append(interval_count_iws[i]*interval)

                interval_count_iws[i] = 1

        if interval != 1:
            currbbv = formbbv(chunk,brdat)
            dist = scp.cityblock(lastbbv,currbbv)

            for i in range(0,numthresholds2):
                if dist <= thresholds2[i]:
                    interval_count_bbv[i]+=1
                else:
                    if interval_count_bbv[i] > 1:
                        bbvphases[i].append(interval_count_bbv[i]*interval)

                    interval_count_bbv[i] = 1

            lastbbv = currbbv
            if lastbbv not in setbbv:
                setbbv.append(lastbbv)

    
    if (len(rem)) > 0:
        diff,sig2 = working_set_dist(sig1,rem,uniq)
        sig1 = sig2
        if sig1 not in setiws:
            setiws.append(sig1)

        for i in range(0,numthresholds1):
            if diff <= thresholds1[i]:
                if (interval_count_iws[i]) > 1:
                    iwsphases[i].append((interval_count_iws[i]*interval)+len(rem))
                    interval_count_iws[i]=1

        if interval != 1:
            currbbv = formbbv(rem,brdat)
            dist = scp.cityblock(lastbbv,currbbv)
            if currbbv not in setbbv:
                setbbv.append(currbbv)

            for i in range(0,numthresholds2):
                if dist <= thresholds2[i]:
                    if (interval_count_bbv[i]) > 1:
                        bbvphases[i].append((interval_count_bbv[i]*interval)+len(rem))
                        interval_count_bbv[i]=1

    for i in range(0,numthresholds1):
        if interval_count_iws[i] > 1:
            iwsphases[i].append(interval_count_iws[i]*interval)

    if interval != 1:
        for i in range(0,numthresholds2):
            if interval_count_bbv[i] > 1:
                bbvphases[i].append(interval_count_bbv[i]*interval)


    iwsphases[numt1-1]=singlephase
    bbvphases[numt2-1]=singlephase

    for i in range(0,numthresholds1):
        iwsstats[i] = get_phase_stats(iwsphases[i],cycles,uniq,setiws)
        
    for i in range(0,numthresholds2):
        bbvstats[i] = get_phase_stats(bbvphases[i],cycles,numbranches,setbbv)

    return iwsstats,bbvstats

def convbranch(dat):
    d = {}
    numbranch=0
    for k,v in dat.iteritems():
        bval = list(reversed(bin(int(v))[2:].zfill(32)))
        branch = int(bval[0])
        sethi = int(bval[1])
        if (branch == 1) and (sethi == 0):
            d[k] = 1
            numbranch+=1
        else:
            d[k] = 0

    return d,numbranch

######################################################################################################

bench = sys.argv[1]

intervals = [1,10,100,1000,10000,100000]

thresholds1 = [0.0,0.1,0.3,0.5,0.7,0.9,1.0]
thresholds2 = [i*2 for i in thresholds1]

mapdat,tracedat = read_data(bench+'pc')

branchdat,numbr = convbranch(mapdat)

iwsfile = open(bench+'iws.dat','w')
bbvfile = open(bench+'bbv.dat','w')

numt1 = len(thresholds1)
numt2 = len(thresholds2)

counter = 0

for i in intervals:
    iws,bbv = gen_data(branchdat,mapdat,tracedat,i,thresholds1, thresholds2)
    for j in range(0,numt1):
        print >>iwsfile, i, thresholds1[j], iws[j]

    for k in range(0,numt2):
        print >>bbvfile, i, thresholds2[k], bbv[k]

iwsfile.close()
bbvfile.close()


