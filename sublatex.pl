#!/usr/bin/perl

use utf8;

use open IO => ':utf8';
use open ':std';

use strict;

# this expands to a single \ in a m/$escape_char/
my $esc = '\\\\';

# the keys in this hash are chars that appear after a $escape_char
my %latextou		= ();

# true for a message if it's parsed
my $parsed = 0;

%latextou =  (
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
	'<'      =>  chr(171),
	'>'      =>  chr(187),
	'\\\\'   =>  '\\'
);

sub 
latextou 
{
	my $str		= shift;

	my $dst	= undef;
	my $magic	= chr(10);

	$str =~ s!$esc$esc!$magic!g;
	while (my ($k, $v) = each %latextou) {
		$str =~ s!$esc$k!$v!g;
		print STDERR "$esc$k\n";
	}
	$str =~ s!$magic!$esc!g;

	print STDERR "\n";
	$dst = $str;

	return $dst;
}

while (<>) {
  chomp;
  print latextou($_), "\n";
}
