#!/usr/bin/perl -w

###############################################
#                                             #
# Script to compile the Itsas Thesis template #
#                                             #
###############################################

use strict;

#
# Check that main file exists
#
my $f = 'Main'; # Name of main file (you can change it, of course)
die "File $f.tex does not exist!\n" unless (-f "$f.tex");

#
# Get the page size from the .tex
#
my $psize = 'a4';                                          # A4 by default
$psize    = 'b5' if (`grep documentclass $f.tex` =~ /b5/); # B5, if specified

#
# To what point compile (first argument). The mode string must include
# numbers from 1 to 4 (e.g. "24" = generate PS and view it, "23" = generate
# PS and PDF, but view none).
#
my $mode  = $ARGV[0] || 3; # Mode:
                           # 1 -> Only .dvi
			   # 2 -> Also .ps
			   # 3 -> Also .pdf
			   # 4 -> View (PDF if possible, else PS)

#
# Check that $mode is OK
#
die "Argument '$mode' contains improper compilation options (1, 2, 3 or 4)!\n" unless ($mode =~ /^[1234]+$/);

# If only argument is '4', assume '3' too:
$mode = '34' if ($mode == 4);

#
# Define PostScript and PDF viewers
#
my $seeps  = 'gv';
my $seepdf = 'acroread';

#
# Other variables
#
my $tmp    = 'tmp';
my $outps  = $f.'.ps';
my $outpdf = $f.'.pdf';

#
# Create the to-do list
#
my @list;
push(@list,"Utils/extract_lyx.pl");                                                 # if LyX files present, convert them to LaTeX
push(@list,"cp -f $f.tex $tmp.tex");                                                # temporal copy of file to compile
push(@list,"latex $tmp");                                                           # run latex
push(@list,"bibtex $tmp");                                                          # run bibtex
push(@list,"latex $tmp");                                                           # second compilation, for cross-references
push(@list,"latex $tmp");                                                           # run latex again
push(@list,"dvips -t $psize $tmp.dvi -o $tmp.ps > /dev/null") unless ($mode == 1);  # convert DVI to PS
push(@list,"mv $tmp.dvi Main.dvi") if ($mode =~ /1/);                               # preserve DVI
push(@list,"ps2pdf $tmp.ps") if ($mode =~ /3/ );                                    # convert PS to PDF
push(@list,"mv -f $tmp.ps  $outps")  if ($mode =~ /2/);                             # save a copy of PS in $outps
push(@list,"mv -f $tmp.pdf $outpdf") if ($mode =~ /3/);                             # save a copy PDF in $outpdf
push(@list,"$seeps $outps > /dev/null &") if ($mode =~ /4/ and $mode !~ /3/);       # open PS and go on
push(@list,"$seepdf $outpdf &")           if ($mode =~ /4/ and $mode =~ /3/);       # open PDF and go on
push(@list,"rm -f $tmp.*");                                                         # delete rubish

#
# To time the steps
#
my $hasi = time(); # +%s date of beginning time
my $oldt = $hasi;
my $str  = '';     # string with all steps

#
# Run commands in list
#
foreach (@list)
{
  my $do = $_;

  my $ok  = 'OK';          # whether step run smoothly
  my $sys = system "$do";  # execute command, and catch exit status
  my $t   = time();
  my $dt  = $t-$oldt;      # seconds this step takes
  my $dt0 = $t-$hasi;      # seconds taken up to this point
  $oldt   = $t;            # ending time for this step
  if ($sys) { $ok = 'KO' } # not-OK if exit status was not 0

  #
  # Save info for later printing
  #
  $str .= sprintf "%-50s   [ %2s ] %6is %6is\n",$do,$ok,$dt,$dt0;

  last if $sys;            # exit if last step failed
};

#
# Print abstract
#
printf "\nABSTRACT [ %1s ]:\n\n%-50s %8s %7s %7s\n\n%1s\n",$f,'Command','Status','Step','Total',$str;
