FILE1 = qsort_small.c

all: qsort_small 

qsort_small: qsort_small.c Makefile
	sparc-elf-gcc -I../../ -O2 -g -fno-builtin-cos -fno-builtin-sin  ${FILE1} -lm -o qsort_small
	sparc-elf-objcopy -O srec --gap-fill 0 qsort_small ../../ram.srec

cpsmall:
	cp qsort_small ../../systest.exe

clean:
	rm -rf qsort_small output*
