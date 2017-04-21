FILE1 = basicmath_small.c cubic.c  isqrt.c rad2deg.c

all: basicmath_small 

basicmath_small: ${FILE1}
	sparc-elf-gcc -I../../ -O2 -g -fno-builtin-cos -fno-builtin-sin ${FILE1} -lm -o basicmath_small
	sparc-elf-objcopy -O srec --gap-fill 0 basicmath_small ../../ram.srec

cpsmall:
	cp basicmath_small ../../systest.exe

clean:
	rm -rf basicmath_small output*
