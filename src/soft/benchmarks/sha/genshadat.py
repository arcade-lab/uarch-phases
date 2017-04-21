#!/usr/bin/env python

import numpy
import sys

def read_data(fname):

    datfile = file(fname)
    data = []

    for dat in datfile:
        if dat != None:
            words = list(dat)
            for w in words:
                data.append(w)

    return data


def main():

    counter = 0

    datf = open("shadat.c", 'w')

    print >>datf, '// Automatically generated data for bare-metal execution.'
    print >>datf, '// SHA small'
    print >>datf, '// Van Bui\n\n'

    data = read_data(sys.argv[1])

#    print >>datf, 'BYTE allindata[311824];'
    print >>datf, 'BYTE allindata[10000];'

#    for i in range(0,len(data)):
    for i in range(0,10000):
        if data[counter] == '\n':
            print >>datf, 'allindata['+str(counter)+']=\'\\n\';'
        else:
            print >>datf, 'allindata['+str(counter)+']=\''+str(data[counter])+'\';'
        counter = counter + 1;

    datf.close()


if __name__ == "__main__":
    main()
