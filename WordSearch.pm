#!/usr/bin/env perl

#-------------------------------------------------------------------------------
# MAKE THIS A MODULE
#

package WordSearch;

BEGIN {
  require Exporter;
  our @ISA     = qw( Exporter );
  our @EXPORT  = qw(
    readLettersFromDictionary
    readDictionaryFromFile
    readGridFromFile
    generateGrid
    printGrid
    flattenGridDirection
    examineGridDirection
  );

  # do not buffer output
  $| = 1
}

#-------------------------------------------------------------------------------
# MODULES NEEDED
#

use strict;
use warnings;
use feature qw( say );
use List::Util qw(min max);

#-------------------------------------------------------------------------------
# SHARED GLOBAL VARIABLES
#
# the 'our' vars are available in any script that includes 'use WordSearch;'
# as long as thety are exported through @EXPORT
#

# ref to Array of Arrays representing the 2D puzzle grid of letters
# - dimensions: R[ows] x C[olumns]
# - R and C are zero-offset
# - (r,c) = (0,0) is on the top-left
our $gridMatrix;

# ref to Hash of Hashes of Arrays representing searchable grid strings extracted
# from rows, columns, and/or diagonals of the grid, depending --directions.
# it should be populated by one or more calls to flattenGridDirection
# example values:
# row 3 (left to right) of a 5-column grid could be:
#   $gridStrings->{r}{abcde} : (2,0)
# same as above, but reversed (i.e. right to left):
#   $gridStrings->{R}{edcba} : (2,4)
# note that the leaf array contains the (r,c) of the beginning of the string
our $gridStrings;

# array representing the set of those letters that can appear in the grid
our @letters;

# hash with dictionary words as keys, and corresponding word lengths as values
# - it is quick to use this data structure to check if a word is in the dict
our %words;

# minimum and maxium length of any word in the words dictionary
# - these will be calculated from the actual dictionary
our $minWordLength;
our $maxWordLength;


#-------------------------------------------------------------------------------
# FUNCTIONS for the PUZZLE GRID
#

# we could assume the set of letters to be simply a-z, but it is more robust
# to examine the dictionary file and calculate the actual set of letters.
# we use a simple awk program encapsulated in a bash script file.
sub readLettersFromDictionary {

  my $fnameDict = shift;
  my $letters = `./count-letters-in-file.sh $fnameDict | cut -d' ' -f1 | sort`;
  @letters = split("\n", $letters);

}

# generate the grid matrix based on letters found in the dictionary
sub generateGrid {

  my ($numRows, $numCols, $fnameDict) = @_;

  readLettersFromDictionary($fnameDict);

  for (my $r = 0; $r < $numRows; $r++) {
    for (my $c = 0; $c < $numCols; $c++) {
      $gridMatrix->[$r][$c] = $letters[rand @letters];
    }
  }

}

sub readGridFromFile {

  my $fnameGrid = shift;

  open(my $fileHandle, "<", $fnameGrid) || die "Can't open $fnameGrid: $!";

  my $rowCurrent = 0;

  while (<$fileHandle>) {
    chomp;
    my @rowLetters = split('', $_);
    @{$gridMatrix->[$rowCurrent]} = @rowLetters;
    $rowCurrent++;
  }

  close($fileHandle);

}

# convert gridMatrix into entries of gridStrings
# for easier iteration and lookup
sub flattenGridDirection {

  my $d = shift;

  my $maxRowIndex = scalar(@{$gridMatrix}) - 1;
  my $maxColIndex = scalar(@{$gridMatrix->[0]}) - 1;

  if    ($d eq 'r') { # [-] left to right
    for my $r (0 .. $maxRowIndex) {
      my @row = @{$gridMatrix->[$r]};
      my $charString = join('', @row);
      @{$gridStrings->{$d}{$charString}} = ($r,0);
    }
  }
  elsif ($d eq 'c') { # [|] top to bottom
    for my $c (0 .. $maxColIndex) {
      my @column;
      for my $r (0 .. $maxRowIndex) {
        push @column, $gridMatrix->[$r][$c];
      }
      my $charString = join('', @column);
      @{$gridStrings->{$d}{$charString}} = (0,$c);
    }
  }
  elsif ($d eq 'R') { # [-] right to left
    for my $r (0 .. $maxRowIndex) {
      my @row = @{$gridMatrix->[$r]};
      my $charString = reverse(join('', @row));
      @{$gridStrings->{$d}{$charString}} = ($r,$maxColIndex);
    }
  }
  elsif ($d eq 'C') { # [|] bottom to top
    for my $c (0 .. $maxColIndex) {
      my @column;
      for my $r (0 .. $maxRowIndex) {
        push @column, $gridMatrix->[$r][$c];
      }
      my $charString = reverse(join('', @column));
      @{$gridStrings->{$d}{$charString}} = ($maxRowIndex,$c);
    }
  }
  elsif ($d eq 's') { # [\] left to right, top to bottom
    # start cells are from the leftmost column and the topmost row
    my $startCells;
    for (my $r = $maxRowIndex; $r >= 0; $r--) {
      push @{$startCells}, [($r,0)];
    }
    for my $c (1 .. $maxColIndex) {
      push @{$startCells}, [(0,$c)];
    }

    # now generate left-to-right \ diagonals beginning in each start cell
    for my $rc (0 .. $#$startCells) {
      my $r = $startCells->[$rc]->[0];
      my $c = $startCells->[$rc]->[1];
      my @diagonal;
      while ($r <= $maxRowIndex and $c <= $maxColIndex) {
        push @diagonal, $gridMatrix->[$r][$c];
        ++$r;
        ++$c;
      }
      my $charString = join('', @diagonal);
      @{$gridStrings->{$d}{$charString}} = ($startCells->[$rc]->[0],$startCells->[$rc]->[1]);
    }
  }
  elsif ($d eq 'z') { # [/] left to right, bottom to top
    # start cells are from the leftmost column and the bottommost row
    my $startCells;
    for my $r (0 .. $maxRowIndex) {
      push @{$startCells}, [($r,0)];
    }
    for my $c (1 .. $maxColIndex) {
      push @{$startCells}, [($maxRowIndex,$c)];
    }
    # now generate left-to-right / diagonals beginning in each start cell
    for my $rc (0 .. $#$startCells) {
      my $r = $startCells->[$rc]->[0];
      my $c = $startCells->[$rc]->[1];
      my @diagonal;
      while ($r >= 0 and $c <= $maxColIndex) {
        push @diagonal, $gridMatrix->[$r][$c];
        --$r;
        ++$c;
      }
      my $charString = join('', @diagonal);
      @{$gridStrings->{$d}{$charString}} = ($startCells->[$rc]->[0],$startCells->[$rc]->[1]);
    }
  }
  elsif ($d eq 'S') { # [\] right to left, bottom to top
    # start cells are from the rightmost column and the bottommost row
    my $startCells;
    for my $r (0 .. $maxRowIndex) {
      push @{$startCells}, [($r,$maxColIndex)];
    }
    for (my $c = $maxColIndex - 1; $c >= 0; $c--) {
      push @{$startCells}, [($maxRowIndex,$c)];
    }
    # now generate left-to-right \ diagonals beginning in each start cell
    for my $rc (0 .. $#$startCells) {
      my $r = $startCells->[$rc]->[0];
      my $c = $startCells->[$rc]->[1];
      my @diagonal;
      while ($r >= 0 and $c >= 0) {
        push @diagonal, $gridMatrix->[$r][$c];
        --$r;
        --$c;
      }
      my $charString = join('', @diagonal);
      @{$gridStrings->{$d}{$charString}} = ($startCells->[$rc]->[0],$startCells->[$rc]->[1]);
    }
  }
  elsif ($d eq 'Z') { # [/] right to left, top to bottom
    # start cells are from the topmost row and the rightmost column
    my $startCells;
    for my $c (0 .. $maxColIndex) {
      push @{$startCells}, [(0,$c)];
    }
    for my $r (1 .. $maxRowIndex) {
      push @{$startCells}, [($r,$maxColIndex)];
    }
    # now generate left-to-right \ diagonals beginning in each start cell
    for my $rc (0 .. $#$startCells) {
      my $r = $startCells->[$rc]->[0];
      my $c = $startCells->[$rc]->[1];
      my @diagonal;
      while ($r <= $maxRowIndex and $c >= 0) {
        push @diagonal, $gridMatrix->[$r][$c];
        ++$r;
        --$c;
      }
      my $charString = join('', @diagonal);
      @{$gridStrings->{$d}{$charString}} = ($startCells->[$rc]->[0],$startCells->[$rc]->[1]);
    }
  }
}

sub examineGridDirection {

  my $d = shift;

  foreach my $str (keys %{$gridStrings->{$d}}) {
    examineString($str,$d);
  }

}

sub examineString {

  my ($str,$d) = @_;

  my $strLength = length($str);

  my $minLength = $strLength < $minWordLength ? $strLength : $minWordLength;
  my $maxLength = $strLength < $maxWordLength ? $strLength : $maxWordLength;

  foreach my $length ($minLength .. $maxLength) {
    foreach my $offset (0 .. $strLength-$length) {
      my $substring = substr($str,$offset,$length);
      if (defined $words{$substring}) {
        recordThisExcitingFind($str,$d,$substring,$offset);
      }
    }
  }
}

sub recordThisExcitingFind {

  my ($str,$d,$substring,$offset) = @_;

  my $r = $gridStrings->{$d}{$str}[0];
  my $c = $gridStrings->{$d}{$str}[1];

  my $reportLine = "[$d ";

  if    ($d eq 'r') { # [-] left to right
    $reportLine .= '- l2r]';
    $reportLine .= sprintf(" (%2i,%2i) ", $r, $c+$offset);
  }
  elsif ($d eq 'c') { # [|] top to bottom
    $reportLine .= '| t2b]';
    $reportLine .= sprintf(" (%2i,%2i) ", $r+$offset, $c);
  }
  elsif ($d eq 'R') { # [-] right to left
    $reportLine .= '- r2l]';
    $reportLine .= sprintf(" (%2i,%2i) ", $r, $c-$offset);
  }
  elsif ($d eq 'C') { # [|] bottom to top
    $reportLine .= '| b2t]';
    $reportLine .= sprintf(" (%2i,%2i) ", $r-$offset, $c);
  }
  elsif ($d eq 's') { # [\] left to right, top to bottom
    $reportLine .= '\ l2r]';
    $reportLine .= sprintf(" (%2i,%2i) ", $r+$offset, $c+$offset);
  }
  elsif ($d eq 'z') { # [/] left to right, bottom to top
    $reportLine .= '/ l2r]';
    $reportLine .= sprintf(" (%2i,%2i) ", $r-$offset, $c+$offset);
  }
  elsif ($d eq 'S') { # [\] right to left, bottom to top
    $reportLine .= '\ r2l]';
    $reportLine .= sprintf(" (%2i,%2i) ", $r-$offset, $c-$offset);
  }
  elsif ($d eq 'Z') { # [/] right to left, top to bottom
    $reportLine .= '/ r2l]';
    $reportLine .= sprintf(" (%2i,%2i) ", $r+$offset, $c+-$offset);
  }

  $reportLine .= $substring;

  say $reportLine;

}

sub printGrid {

  my @fileContent;

  for (my $r = 0; $r < scalar(@{$gridMatrix}); $r++) {
    my @row = @{$gridMatrix->[$r]};
    push @fileContent, join('', @row);
  }

  say join("\n", @fileContent);
}

sub readDictionaryFromFile {

  my $fnameDict = shift;
  open(my $fileHandle, "<", $fnameDict) || die "Can't open $fnameDict: $!";

  while (<$fileHandle>) {
    chomp;
    $words{$_} = length;
  }

  close($fileHandle);

  my @lengths = values(%words);
  $minWordLength = min(@lengths);
  $maxWordLength = max(@lengths);
}

sub writeFile {

  my ($fileName,$fileContent) = @_;

  open(my $fileHandle, ">", $fileName) || die "Can't open $fileName: $!";

  say $fileHandle $fileContent;

  close($fileHandle);

}

#-------------------------------------------------------------------------------
# OTHER
#

# true return value is needed in any module
1;
