OBJ = main.o fftmisc.o  fourierf.o
FILE = main.c fftmisc.c  fourierf.c
FILE2 = main2.c fftmisc.c  fourierf.c
CFLAGS = -static -O3 -g

fft: main.c fftmisc.c  fourierf.c 
	sparc-elf-gcc -I../../ -O2 -g -fno-builtin-cos -fno-builtin-sin ${FILE} -lm -o fft
	sparc-elf-objcopy -O srec --gap-fill 0 fft ../../ram.srec

fftinv: main2.c fftmisc.c  fourierf.c 
	sparc-elf-gcc -I../../ -O2 -g -fno-builtin-cos -fno-builtin-sin ${FILE2} -lm -o fftinv
	sparc-elf-objcopy -O srec --gap-fill 0 fftinv ../../ram.srec

cp:
	cp fft ../../systest.exe

cpinv:
	cp fftinv ../../systest.exe

clean:
	rm -rf *.o fft fftinv output*
