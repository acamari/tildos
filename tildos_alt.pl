#!/usr/bin/perl

# tildos: Script for using LaTeX-like metacharacters in irssi

# sublatex: 
# \a  converts to spanish acute accented a,   (unicode code point = 225) 
# \e  converts to spanish acute accented e,   (unicode code point = 233) 
# \:e converts to e with diaeresis on top,    (unicode code point = 235) 
# \i  converts to spanish acute accented i,   (unicode code point = 237) 
# \:i converts to i with diaeresis on top,    (unicode code point = 239)
# \~n converts to spanish tilde accented n,   (unicode code point = 241) 
# \o  converts to spanish acute accented o,   (unicode code point = 243) 
# \u  converts to spanish acute accented u,   (unicode code point = 250) 
# \:u converts to u with diaeresis on top,    (unicode code point = 252) 
# \?  converts to inverted question mark,     (unicode code point = 191)
# \!  converts to inverted exclamation mark,  (unicode code point = 161)

use utf8;
use open IO => ':utf8';
use encoding qw/utf8/;

use strict;

use vars qw/$VERSION %IRSSI/;

use Irssi;

$VERSION = "0.0";
%IRSSI = (
    name => 'tildos',
    description => 'Script for using LaTeX-like metacharacters in irssi',
    authors => "Rafael Díaz de León Plata, Abel Camarillo",
    contact => 'leon@elinter.net',
    license => 'BSD',
);

my %sublatex_to_unicode = (
  'a'  => 'á',
  'A'  => 'Á',
  'e'  => 'é',
  'E'  => 'É',
  ':e' => 'ë',
  ':E' => 'Ë',
  'i'  => 'í',
  'I'  => 'Í',
  ':i' => 'ï',
  ':I' => 'Ï',
  'n' => 'ñ',
  'N' => 'Ñ',
  'o'  => 'ó',
  'O'  => 'Ó',
  'u'  => 'ú',
  'U'  => 'Ú',
  ':u' => 'ü',
  ':U' => 'Ü',
  'c'  => '©',
  'r'  => '®',
  '!'  => '¡',
  't'  => '™',
);

sub leos_replace
{
  my ($string) = @_;
  my @matches;

  #For the sake of comedy
  $string =~ s/\\\\/<THEINFAMOUSTILDOSPLACEHOLDER>/go;
  @matches = $string =~ m/\\((:|~)?(\w|!){1})/go;
  if(@matches){
    my @matches = keys %{ { map { $_ => 1 } @matches }};
    #use byte;
    for(@matches){
      next if $_ eq '';
      $string =~ s/\\$_/$sublatex_to_unicode{$_}/g;
    }
    #no byte;
  }
#Troublesome character
  $string =~ s/\x{5c}\?/¿/g;
  $string =~ s/<THEINFAMOUSTILDOSPLACEHOLDER>/\\/go;
 
  return $string;
}

sub filter_string
{
  my ($string, $server, $window) = @_;
  if($string and $window){
    $string = leos_replace($string);
    Irssi::signal_stop();
    $window->command('MSG '. $window->{name} ." $string");
  }
}

Irssi::signal_add_first('send text', "filter_string");
