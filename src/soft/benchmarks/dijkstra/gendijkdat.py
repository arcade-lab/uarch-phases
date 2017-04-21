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

    datf = open("dijkdat.c", 'w')

    print >>datf, '// Automatically generated data for bare-metal execution.'
    print >>datf, '// Dijikstra small input'
    print >>datf, '// Van Bui\n\n'

    data = read_data(sys.argv[1])

    for i in range(0,100):
        for j in range(0,100):
            print >>datf, 'AdjMatrix['+str(i)+']['+str(j)+']='+ str(data[counter])+';'
            counter = counter + 1

    datf.close()


if __name__ == "__main__":
    main()
