#!/usr/bin/perl -w

###############################################
#                                             #
# Script to convert LyX files to kosher LaTeX #
#                                             #
###############################################

use strict;

#--------------------------------------------------------------------------------#

sub extract
{
  # This subroutine extracts and returns the text between "% LyX specific LaTeX commands" 
  # and"\end{document}" in a file given as argument. Then removes "\begin{document}"

  my $file = $_[0];

  my @lines = `cat $file`;

  my $doprint   = 0;
  my $extracted = '';
  foreach my $line (@lines)
  {
    if ($doprint)
    {
      if ($line =~ /\\end{document}/) { $doprint = 0 }
      else                            { $extracted .= $line };
    }
    else { $doprint = 1 if ($line =~ /% LyX specific LaTeX commands/) };
  };

  # Remove unwanted \begin{document}
  $extracted =~ s/\\begin{document}//;

  # Remove all \usepackage{whatever}
  $extracted =~ s/\\usepackage\{.*\}\n//;

  return $extracted;
};

#--------------------------------------------------------------------------------#

# Get list of LyX files:
chomp(my @flist = `ls *.lyx`);

# Loop through all:
foreach my $file (@flist)
{
  my $base = $file;
  $base    =~ s/\.lyx//;

  # Convert LyX to LaTeX:
  system "lyx -e latex $file";

  # Extract only "meat" from the recently created LaTeX:
  my $string = &extract("$base.tex");

  # Put meat, and only meat, back into file:
  open(TEX,">$base.tex");
  print TEX $string;
  close(TEX)
};
