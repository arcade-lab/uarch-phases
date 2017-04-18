# Errors, mistakes, ommissions in this file will prevent 
# latex from running correctly...

# In the next declaration, "uname" is a standard Unix command which prints
# the name of the current system.
os:= $(shell uname -s)

ifeq ($(os),Linux)
	ACROBAT:=acroread
	DETEX:=cat
	SPELL:=ispell -t
endif

ifeq ($(os),Darwin)
	ACROBAT:=open
	DETEX:=detex
	SPELL:=echo 'ispell not instaled' ; ls 
endif

MAIN=main
TEXFILES=${wildcard *.tex} 
FIGURES=${wildcard data/*.pdf} 
STYLE=${wildcard *.sty} 
CLASS=${wildcard *.cls} 
SOURCES=${wildcard *.bib} 
MAKEFILE=Makefile
INFILES=$(TEXFILES) $(FIGURES) $(STYLE) $(CLASS) $(SOURCES) $(MAKEFILE)
LATEX=pdflatex
BIBTEX=bibtex
FONTS=pdffonts

default: $(MAIN).pdf

$(MAIN).pdf: $(INFILES)
	$(LATEX) $(MAIN)
	$(BIBTEX) $(MAIN)
	$(LATEX) $(MAIN)
	$(LATEX) $(MAIN)

view: $(MAIN).pdf
	$(ACROBAT) $< &

clean:
	rm -fv *.bbl *.dvi *.ps *.aux *.blg *.log $(MAIN).pdf *.lof *.lot *.toc *.out data/*-eps-converted-to.pdf 

remake: clean default

wordcount: $(TEXFILES)
	$(DETEX) $(TEXFILES) | wc

spell: $(TEXFILES)
	$(SPELL) $(TEXFILES)
