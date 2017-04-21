#!/usr/bin/env python

import random
import numpy as np

def genmatrix(r,c,name):
    size = r*c
    a = np.arange(size).reshape(r,c)
    print >> fdat,'volatile int '+name+'['+str(r)+']'+'['+str(c)+'];'
    for i in range(0,r):
        for j in range(0,c):
            randval = random.randrange(1,100)
            print >>fdat, name+'['+str(i)+']'+'['+str(j)+']='+str(randval)+';'
            a[i][j] = randval
            
    return a

rows = 10
cols = 10

fdat = open("matmuldat.c", 'w')

print >>fdat, 'int row=ROWSIZE;'
print >>fdat, 'int col=COLSIZE;'

m1 = np.matrix(genmatrix(rows,cols,'m1'))
m2 = np.matrix(genmatrix(rows,cols,'m2'))

res = m1*m2
ares = np.array(res)

print >>fdat, 'volatile int ans['+str(rows)+']'+'['+str(cols)+'];'

for i in range(0,rows):
    for j in range(0,cols):
        print >>fdat, 'ans['+str(i)+']'+'['+str(j)+']='+str(ares[i][j])+';'

print >>fdat, 'volatile int res['+str(rows)+']'+'['+str(cols)+'];'

for i in range(0,rows):
    for j in range(0,cols):
        print >>fdat, 'res['+str(i)+']'+'['+str(j)+']=0;'

fdat.close()

print 'm1:', m1
print 'm2: ', m2
print 'ans: ', ares
