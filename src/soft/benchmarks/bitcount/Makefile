FILE = bitcnt_1.c bitcnt_2.c bitcnt_3.c bitcnt_4.c bitcnts.c bitfiles.c bitstrng.c bstr_i.c 

bitcnts: ${FILE} Makefile
	sparc-elf-gcc -I../../ -O2 -g -fno-builtin-cos -fno-builtin-sin ${FILE} -o bitcnts
	sparc-elf-objcopy -O srec --gap-fill 0 bitcnts ../../ram.srec
cp:
	cp bitcnts ../../systest.exe
clean:
	rm -rf bitcnts output*
