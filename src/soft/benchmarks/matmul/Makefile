FILE1 = matmul.c

all: matmul10x10

matmul10x10: ${FILE1}
	sparc-elf-gcc -I../../ -O2 -g -fno-builtin-cos -fno-builtin-sin ${FILE1} -lm -o matmul10x10
	sparc-elf-objcopy -O srec --gap-fill 0 matmul10x10 ../../ram.srec

clean:
	rm -rf matmul10x10
