# By default, the code is compiled for a "big endian" machine.
# To compile on a "little endian" machine set the LITTLE_ENDIAN flag.
# To make smaller object code, but run a little slower, don't use UNROLL_LOOPS.
# To use NIST's modified SHA of 7/11/94, define USE_MODIFIED_SHA

CC = gcc
CFLAGS = -O3 -Wall 

sha:	sha_driver.c sha.c
	sparc-elf-gcc -I../../ -O2 -g -fno-builtin-cos -fno-builtin-sin sha.c sha_driver.c -o sha
	sparc-elf-objcopy -O srec --gap-fill 0 sha ../../ram.srec

cp:
	cp sha ../../systest.exe

clean:
	rm -rf *.o sha output*
