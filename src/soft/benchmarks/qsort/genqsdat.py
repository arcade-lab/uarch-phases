#!/usr/bin/env python

import numpy
import sys

def read_data(fname):

    datfile = file(fname)
    data = []

    for dat in datfile:
        if dat != None:
            words = dat.split()
            for w in words:
                data.append(w)

    return data


def main():

    counter = 0

    datf = open("qsdat.c", 'w')

    print >>datf, '// Automatically generated data for bare-metal execution.'
    print >>datf, '// QuickSort small'
    print >>datf, '// Van Bui\n\n'

    data = read_data(sys.argv[1])

    for i in range(0,8000):
#        print >>datf, 'strcpy(array['+str(i)+'].qstring,"'+ str(data[i])+'");'
        print >>datf, 'sprintf(array['+str(i)+'].qstring,"%s","'+ str(data[i])+'");'

    datf.close()


if __name__ == "__main__":
    main()
