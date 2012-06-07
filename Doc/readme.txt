# Put in .tcsh o .login, o exec by hand:

setenv BIBINPUTS ::./Config # look for .bib in the "regular" places (the ::),
                            # and in the Config/ folder inside dir we are at

setenv BSTINPUTS ::./Config # idem, for .bst files

setenv TEXINPUTS ::./Config # idem, for the .cls file

# To compile:

./Utils/run_latex.pl

# or:

latex  Main.tex
bibtex Main
latex  Main.tex
latex  Main.tex
dvips -t a4 Main.dvi -o Main.ps
ps2pdf Main.ps

# Delete temporary files:

rm -f Main.aux Main.b?? Main.toc Main.dvi Main.mtc* Main.log Main.ps

# See the result:

acroread Main.pdf
