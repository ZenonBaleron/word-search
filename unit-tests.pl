#!/usr/bin/env perl

#-------------------------------------------------------------------------------
# MODULES NEEDED
#

use strict;
use warnings;
use feature qw(say);
use Digest::MD5 qw(md5_hex);
use Test::More qw( no_plan );

# . is no longer in @INC as of perl 5.26, so we need to make it explicit
# (we need this to include the WordSearch module below)
use FindBin qw( $RealBin );
use lib $RealBin;

# this is where we implement most of the Word Search puzzle functions
# (this will not work without the RealBin above)
use WordSearch;

#-------------------------------------------------------------------------------

readLettersFromDictionary('test-files/digits-dictionary.txt');

is(
  join('', @WordSearch::letters),
  'efghinorstuvwxz',
  'readLettersFromDictionary digits-dictionary.txt'
);

#-------------------------------------------------------------------------------

readGridFromFile('test-files/digits-grid.txt');
readDictionaryFromFile('test-files/digits-dictionary.txt');
my $last_line = `./word-search-solver --dict test-files/digits-dictionary.txt --grid test-files/digits-grid.txt --dir C | tail -1`;
chomp $last_line;

is(
  $last_line,
  '[C | b2t] ( 4,39) three',
  'bottom-to-top match from digits'
);

#-------------------------------------------------------------------------------

# TODO: more unit test

#-------------------------------------------------------------------------------


