#!/usr/bin/perl

# tildos: Script for using LaTeX-like metacharacters in irssi

# sublatex: 
#
# Unicode code points got with ord();
#
# \a  converts to spanish acute accented a,   (unicode code point = 225) 
# \e  converts to spanish acute accented e,   (unicode code point = 233) 
# \:e converts to e with diaeresis on top,    (unicode code point = 235) 
# \i  converts to spanish acute accented i,   (unicode code point = 237) 
# \:i converts to i with diaeresis on top,    (unicode code point = 239)
# \~n converts to spanish tilde accented n,   (unicode code point = 241) 
# \o  converts to spanish acute accented o,   (unicode code point = 243) 
# \u  converts to spanish acute accented u,   (unicode code point = 250) 
# \:u converts to u with diaeresis on top,    (unicode code point = 252) 
# \?  converts to inverted question mark,     (unicode code point = 191)
# \!  converts to inverted exclamation mark,  (unicode code point = 161)

use utf8;

use open IO => ':utf8';
use open ':std';

use strict;

# this expands to a single \ in a m/$escape_char/
my $escape_char = '\\\\';

# the keys in this hash are chars that appear after a $escape_char
my %sublatex_to_unicode; 

%sublatex_to_unicode =  (
'a'      =>  chr(225),
'A'      =>  chr(193),
'e'      =>  chr(233),
'E'      =>  chr(201),
':e'     =>  chr(235),
':E'     =>  chr(203),
'i'      =>  chr(237),
'I'      =>  chr(205),
':i'     =>  chr(239),
':I'     =>  chr(207),
'~n'     =>  chr(241),
'~N'     =>  chr(209),
'o'      =>  chr(243),
'O'      =>  chr(211),
'u'      =>  chr(250),
'U'      =>  chr(218),
':u'     =>  chr(252),
':U'     =>  chr(220),
'\?'     =>  chr(191),
'c'      =>  chr(169),
'r'      =>  chr(174),
'!'      =>  chr(161),
't'      =>  chr(848),
'\\\\'   =>  '\\'
);

sub sublatex_to_unicode 
{
  my ($string) = @_;
  my $dest;

  pos($string) = 0;

  CHAR :
  while ($string =~ m/\G./g) {
# debug
# print STDERR "current pos(", pos($string), ");";
# this gets the current position in the string in a C fashion (0 based)
    my $curr_pos = (--pos($string));

    for my $key (keys %sublatex_to_unicode) {
# search for something to substitute on the string
# if you found it then grow our current position to the length of that
# substitution
      if ($string =~ m"\G($escape_char$key)"c ) {
        my $found = $1;
        my $replace = $sublatex_to_unicode{$key};
        $dest .= $replace;
# debug      
# print STDERR "search for ($escape_char$_) in ('".  substr($string, pos($string)). "', pos: ", pos($string), ") dest ($dest)\n";
        pos($string) += length($found);
        next CHAR;
      } else {
        #  returns to the inital position on this iteration if this regex didn't
        #  match
        pos($string) = $curr_pos;
      }
    }
# if we didn't match anything copy the original char to $dest
    $dest .= substr($string, $curr_pos,1);
    pos($string) = $curr_pos + 1;
  }

  return $dest;
}

while (<>) {
  chomp;
  print sublatex_to_unicode($_), "\n";
}
