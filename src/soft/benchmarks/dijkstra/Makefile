all: dijkstra_small

dijkstra_small: dijkstra_small.c Makefile
	sparc-elf-gcc -I../../ -O2 -g -fno-builtin-cos -fno-builtin-sin dijkstra_small.c -o dijkstra_small
	sparc-elf-objcopy -O srec --gap-fill 0 dijkstra_small ../../ram.srec

cpsmall:
	cp dijkstra_small ../../systest.exe

clean:
	rm -rf dijkstra_small output*
