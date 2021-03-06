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
## File:        psprocess.py
## Author:      Van Bui - ARCADE @ Columbia University
## Description: Processes raw processor signal data (non-pc data) 
##              and generates phase stats for CPI and ITD 
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

def decode_signal(dat):
    d = {}

    for k,v in dat.iteritems():
        bval = list(reversed(bin(int(v))[2:].zfill(32)))
        annul = int(bval[13],2)   # 1 means instruction is annulled
        pv = int(bval[14],2)      # 1 means pipeline is not valid
        icohold = int(bval[0],2)
        dcohold = int(bval[1],2)
        fpohold = int(bval[2],2)

        d_annul = int(bval[5],2)
        d_pv = int(bval[6],2)
        a_annul = int(bval[7],2)
        a_pv = int(bval[8],2)
        e_annul = int(bval[9],2)
        e_pv = int(bval[10],2)
        m_annul = int(bval[11],2)
        m_pv = int(bval[12],2)
        x_annul = int(bval[13],2)
        x_pv = int(bval[14],2)

        rfe1 = int(bval[15],2)
        rfe2 = int(bval[16],2)

        wreg = int(bval[25],2)

        xinst = int(bval[22]+bval[21],2)

        xload = int(bval[24])

        if d_annul or d_pv or a_annul or a_pv:
            fe_bubble = '1'
        else:
            fe_bubble = '0'
            
        if (d_annul == 0) or (d_pv == 0) or (a_annul == 0) or (a_pv == 0) or (rfe1 == 1) or (rfe2 == 1):
            fe_activity = '1'
        else:
            fe_activity = '0'

        if e_annul or e_pv or m_annul or m_pv or x_annul or x_pv:
            be_bubble = '1'
        else:
            be_bubble = '0'

        if (e_annul==0) or (e_pv==0) or (m_annul==0) or (m_pv==0) or (x_annul==0) or (x_pv==0) or (wreg==1):        
            be_activity = '1'
        else:
            be_activity = '0'

        halt = 0
        hold = ((icohold and dcohold) and fpohold) # 0 means there is a hold
        if hold == 0:
            halt = 1
        retired = 1
        if (pv==1) or (annul==1) or (hold == 0):
            retired = 0
            
        topdown=0
        if icohold==0:
            topdown=1
        elif ((dcohold==0) or (fpohold==0)):
            topdown=2
        elif (pv==1) or (annul==1):
            topdown=3
            
        if icohold==0 and dcohold==0 and fpohold==0:
            topdownD=0
        elif icohold==0 and dcohold==0 and fpohold==1:
            topdownD=1
        elif icohold==0 and dcohold==1 and fpohold==0:
            topdownD=2
        elif icohold==0 and dcohold==1 and fpohold==1:
            topdownD=3
        elif icohold==1 and dcohold==0 and fpohold==0:
            topdownD=4
        elif icohold==1 and dcohold==0 and fpohold==1:
            topdownD=5
        elif icohold==1 and dcohold==1 and fpohold==0:
            topdownD=6
        else:
            topdownD = int(fe_bubble+fe_activity+be_bubble+be_activity,2)+7

        if icohold==0:
            topdown2=0
        elif (dcohold==0):
            if xload == 0:
                topdown2 = 1
            else:
                topdown2 = 2
        elif fpohold==0:
            topdown2=3
        elif (pv==1) or (annul==1):
            topdown2=4
        elif xinst==0:
            topdown2=5
        elif xinst==1:
            topdown2=6
        elif xinst==2:
            topdown2=7
        else:
            topdown2=8

        d[k] = [halt,retired,topdown,topdown2]

    return d

def get_cpi(dat, mapdat):

    cycles = len(dat)
    retired_inst = 0

    for d in dat:
        dsigs = mapdat[d]

        if dsigs[1] == 1:
            retired_inst+=1

    if retired_inst == 0:
        cpi = -1.0
    else:
        cpi = (cycles)/float(retired_inst)
    
    return cpi

def get_phase_stats(phase,cycles,setphase,iscpi):

    pcount = {}
    sigstd = []
    
    if iscpi:
        sigstd.append(np.std(setphase))
    else:
        for s in setphase:
            sigstd.append(np.std(s))

    if len(phase) > 0:
        for i in set(phase):
            pcount[i] = phase.count(i)

        stats = str(min(phase))+' '+str(np.mean(phase))+' '+str(max(phase))+' '+str(np.std(phase))+' '+str(len(phase))+' '+str(sum(phase))+' '+str(cycles) +' '+str(len(setphase))+' '+str(np.mean(sigstd))+' '+str(np.std(sigstd))
        for k,v in pcount.iteritems():
            stats = stats + ' '+str(k)+ ' '+str(v)

    else:
        stats = '0 0 0 0 0 0'+' '+str(cycles)+' 0 0 0'

    return stats

def get_topdown(dat,mapdat):

    signature = [0,0,0,0]
    
    for d in dat:
        dsigs = mapdat[d]
        td = dsigs[2]
        signature[td]+=1

    sigsum = float(sum(signature))

    normsig = []

    if sigsum == 0:
        normsig = [0.0 for b in range(0,len(signature))]
    else:
        normsig = [b/sigsum for b in signature]

    return normsig

def get_topdownd(dat,mapdat):

    signature = [0 for i in range(0,9)]
    
    for d in dat:
        dsigs = mapdat[d]
        tdd = dsigs[3]
        signature[tdd]+=1

    sigsum = float(sum(signature))

    normsig = []

    if sigsum == 0:
        normsig = [0.0 for b in range(0,len(signature))]
    else:
        normsig = [b/sigsum for b in signature]

    return normsig


def gen_data(mapdat, tracedat, interval,thresholds1,thresholds2):

    cycles = float(len(tracedat))

    singlephase = [int(cycles)]

    chunkdat = chunker(tracedat,interval)
    numchunks = len(chunkdat)
    last = chunkdat.pop(0)

    rem = []
    if (numchunks*interval) != cycles:
        endind = numchunks*interval
        for i in range(endind, int(cycles)):
            rem.append(tracedat[i])

    numthresholds1 = len(thresholds1)
    numthresholds2 = len(thresholds2)

    lastcpi = get_cpi(last,mapdat)
    cpi_count = [1 for i in range(0,numthresholds1)] 
    cpiphases = {}
    cpistats = {}
    for i in range(0,numthresholds1):
        cpiphases[i] = []

    lasttopdown = get_topdown(last,mapdat)
    tdphases = {}
    tdstats = {}
    tdcount = [1 for i in range(0,numthresholds2)] 
    for i in range(0,numthresholds2):
        tdphases[i] = []    

    lasttopdownd = get_topdownd(last,mapdat)
    tddphases = {}
    tddstats = {}
    tddcount = [1 for i in range(0,numthresholds2)] 
    for i in range(0,numthresholds2):
        tddphases[i] = []    
    
    allcpidiff = []
    cpiset = []
    cpiset.append(lastcpi)
    
    tdset = []
    tdset.append(lasttopdown)
    
    tddset = []
    tddset.append(lasttopdownd)

    for chunk in chunkdat:
        currcpi = get_cpi(chunk,mapdat)
        if currcpi not in cpiset:
            cpiset.append(currcpi)

        if currcpi==lastcpi:
            cpidiff = 0.0
        elif (currcpi == -1.0) or (lastcpi == -1.0):
            cpidiff = interval+1
        else:
            cpidiff = abs(currcpi-lastcpi)
        
        allcpidiff.append(cpidiff)
        lastcpi = currcpi
        
        currtopdown = get_topdown(chunk,mapdat)
        dist = scp.cityblock(lasttopdown,currtopdown)

        lasttopdown = currtopdown
        if lasttopdown not in tdset:
            tdset.append(lasttopdown)

        for i in range(0,numthresholds2):
            if dist <= thresholds2[i]:
                tdcount[i]+=1
            else:
                if tdcount[i] > 1:
                    tdphases[i].append(tdcount[i]*interval)
                tdcount[i] = 1
      
        currtopdownd = get_topdownd(chunk,mapdat)
        dist = scp.cityblock(lasttopdownd,currtopdownd)

        lasttopdownd = currtopdownd
        if lasttopdownd not in tddset:
            tddset.append(lasttopdownd)

        for i in range(0,numthresholds2):
            if dist <= thresholds2[i]:
                tddcount[i]+=1
            else:
                if tddcount[i] > 1:
                    tddphases[i].append(tddcount[i]*interval)
                tddcount[i] = 1

    if len(rem) > 0:
        currcpi = get_cpi(rem,mapdat)
        if currcpi not in cpiset:
            cpiset.append(currcpi)

        currtopdown = get_topdown(rem,mapdat)
        if currtopdown not in tdset:
            tdset.append(currtopdown)
        dist = scp.cityblock(lasttopdown,currtopdown)

        for i in range(0,numthresholds2):
            if dist <= thresholds2[i]:
                if (tdcount[i]) > 1:
                    tdphases[i].append((tdcount[i]*interval)+len(rem))
                    tdcount[i]=1

        currtopdownd = get_topdownd(rem,mapdat)
        if currtopdownd not in tddset:
            tddset.append(currtopdownd)
        dist = scp.cityblock(lasttopdownd,currtopdownd)

        for i in range(0,numthresholds2):
            if dist <= thresholds2[i]:
                if (tddcount[i]) > 1:
                    tddphases[i].append((tddcount[i]*interval)+len(rem))
                    tddcount[i]=1

    for i in range(0,numthresholds2):
        if tdcount[i] > 1:
            tdphases[i].append(tdcount[i]*interval)

        if tddcount[i] > 1:
            tddphases[i].append(tddcount[i]*interval)

    maxcpi = float(max(cpiset))

    allreldiff = []

    for d in allcpidiff:
        relcpidiff = d/maxcpi
        for i in range(0,numthresholds1):
            if (d == (interval+1)):
                if thresholds1[i] == max(thresholds1):
                    cpi_count[i]+=1
                elif cpi_count[i] > 1:
                    cpiphases[i].append(cpi_count[i]*interval)
                    cpi_count[i]=1            
            elif relcpidiff <= thresholds1[i]:
                cpi_count[i]+=1
            else:
                if cpi_count[i] > 1:
                    cpiphases[i].append(cpi_count[i]*interval)
                cpi_count[i]=1

    
    if len(rem) > 0:
        currcpi = get_cpi(rem,mapdat)
        if currcpi==lastcpi:
            cpidiff = 0.0
        elif (currcpi == -1.0) or (lastcpi == -1.0):
            cpidiff = interval+1
        else:
            cpidiff = abs(currcpi-lastcpi)
        
        relcpidiff = cpidiff/maxcpi
        
        for i in range(0,numthresholds1):
            if (cpidiff == (interval+1)):
                if cpi_count[i] > 1:
                    cpiphases[i].append(cpi_count[i]*interval)
            elif relcpidiff <= thresholds1[i]:
                if ((cpi_count[i])) > 1:
                    cpiphases[i].append((cpi_count[i]*interval)+len(rem))
            else:
                if cpi_count[i] > 1:
                    cpiphases[i].append((cpi_count[i]*interval))
    else:
        for i in range(0,numthresholds1):
            if cpi_count[i] > 1:
                cpiphases[i].append((cpi_count[i]*interval))

    cpiphases[numt1-1]=singlephase
    tdphases[numt2-1]=singlephase
    tddphases[numt2-1]=singlephase

    for i in range(0,numthresholds1):
        cpistats[i] = get_phase_stats(cpiphases[i], cycles,cpiset,1)

    for i in range(0,numthresholds2):
        tdstats[i] = get_phase_stats(tdphases[i], cycles,tdset,0)

    for i in range(0,numthresholds2):
        tddstats[i] = get_phase_stats(tddphases[i], cycles,tddset,0)

    return cpistats,tdstats,tddstats


######################################################################################################

bench = sys.argv[1]

intervals = [1,10,100,1000,10000,100000]

thresholds1 = [0.0,0.1,0.3,0.5,0.7,0.9,1.0]
thresholds2 = [i*2 for i in thresholds1]

mapdat,tracedat = read_data(bench+'ps')

psdat = decode_signal(mapdat)

cpifile = open(bench+'cpi.dat','w')
tdfile = open(bench+'td.dat','w')
tddfile = open(bench+'tdd.dat','w')

numt1 = len(thresholds1)
numt2 = len(thresholds2)

counter = 0
for i in intervals:
    cpi,td,tdd = gen_data(psdat, tracedat,i,thresholds1,thresholds2)

    for j in range(0,numt1):
        print >>cpifile, i, thresholds1[j], cpi[j]

    for j in range(0,numt2):
        print >>tdfile, i, thresholds2[j], td[j]

    for j in range(0,numt2):
        print >>tddfile, i, thresholds2[j], tdd[j]

cpifile.close()
tdfile.close()
tddfile.close()

