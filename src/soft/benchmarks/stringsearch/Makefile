FILE1 = bmhasrch.c  bmhisrch.c  bmhsrch.c  pbmsrch_small.c 

all: search_small 

search_small: ${FILE1} Makefile
	sparc-elf-gcc -I../../ -O2 -g -fno-builtin-cos -fno-builtin-sin ${FILE1} -o search_small
	sparc-elf-objcopy -O srec --gap-fill 0 search_small ../../ram.srec

cpsmall:
	cp search_small ../../systest.exe

clean:
	rm -rf search_small output*
