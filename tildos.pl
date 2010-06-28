#!/usr/bin/perl

# tildos: Script for using LaTeX-like metacharacters in irssi


# XXX: Remember to use irssi under an environment that supports LC_ALL and LANG
# XXX: If you use this under OpenBSD use /set term_charset utf-8

# sublatex: 
#
# Unicode code points from the Unicode Standard
# (http://www.unicode.org/charts/PDF/U0080.pdf)
#
# \A	LATIN CAPITAL LETTER A WITH ACUTE;	U+00C1
# \a	LATIN SMALL LETTER A WITH ACUTE;	U+00E1
# \:A	LATIN CAPITAL LETTER A WITH DIAERESIS;	U+00C4
# \:a	LATIN SMALL LETTER A WITH DIAERESIS;	U+00E4
# \E	LATIN CAPITAL LETTER E WITH ACUTE;	U+00C9
# \e	LATIN SMALL LETTER E WITH ACUTE;	U+00E9
# \:E	LATIN CAPITAL LETTER E WITH DIAERESIS;	U+00CB 
# \:e	LATIN SMALL LETTER E WITH DIAERESIS;	U+00EB 
# \I	LATIN CAPITAL LETTER I WITH ACUTE;	U+00CD
# \i	LATIN SMALL LETTER I WITH ACUTE;	U+00ED
# \:I	LATIN CAPITAL LETTER I WITH DIAERESIS;	U+00CF 
# \:i	LATIN SMALL LETTER I WITH DIAERESIS;	U+00EF 
# \N	LATIN CAPTIAL LETTER N WITH TILDE;	U+00D1
# \n	LATIN SMALL LETTER N WITH TILDE;	U+00F1
# \O	LATIN CAPITAL LETTER O WITH ACUTE;	U+00D3
# \o	LATIN SMALL LETTER O WITH ACUTE;	U+00F3
# \:O	LATIN CAPITAL LETTER O WITH DIAERESIS;	U+00D6 
# \:o	LATIN SMALL LETTER O WITH DIAERESIS;	U+00F6 
# \U	LATIN CAPITAL LETTER U WITH ACUTE;	U+00DA
# \u	LATIN SMALL LETTER U WITH ACUTE;	U+00FA
# \:U	LATIN CAPITAL LETTER U WITH DIAERESIS;	U+00DC
# \:u	LATIN SMALL LETTER U WITH DIAERESIS;	U+00FC
# \?	INVERTED QUESTION MARK;			U+00BF
# \!	INVERTED EXCLAMATION MARK;		U+00A1
# \<	RIGHT-POINTING DOUBLE ANGLE QUOTATION;	U+00AB
# \<	LEFT-POINTING DOUBLE ANGLE QUOTATION;	U+00BB

use utf8;

use strict;
use warnings;

use Encode;
use open IO => ':encoding(UTF-8)';
use open ':std';

use Irssi;

our $VERSION = "0.1";
our %IRSSI = (
	authors => "Abel Abraham Camarillo Ojeda",
	contact => 'acamari@the00z.org',
	name => 'tildos.pl',
	description => 'Script for writing using LaTeX like metachars',
	license => 'ISC',
 );

my $debug = 1;

# this expands to a single \ in a m/$escape_char/
my $esc = chr(0x5c);

# the keys in this hash are chars that appear after a $escape_char
my %latextou		= ();

# true for a message if it's parsed
my $parsed = 0;

%latextou =  (
	'A'      => "\N{U+00C1}",
	'a'      => "\N{U+00E1}",
	':A'      => "\N{U+00C4}",
	':a'      => "\N{U+00E4}",
	'E'      => "\N{U+00C9}",
	'e'     => "\N{U+00E9}",
	':E'     => "\N{U+00CB}",
	':e'      => "\N{U+00EB}",
	'I'      => "\N{U+00CD}",
	'i'     => "\N{U+00ED}",
	':I'     => "\N{U+00CF}",
	':i'      => "\N{U+00EF}",
	'N'      => "\N{U+00D1}",
	'n'      => "\N{U+00F1}",
	'O'      => "\N{U+00D3}",
	'o'      => "\N{U+00F3}",
	':O'      => "\N{U+00D6}",
	':o'     => "\N{U+00F6}",
	'U'     => "\N{U+00DA}",
	'u'     => "\N{U+00FA}",
	':U'      => "\N{U+00DC}",
	':u'      => "\N{U+00FC}",
	'\?'      => "\N{U+00BF}",
	'!'      => "\N{U+00A1}",
	'<'      => "\N{U+00AB}",
	'>'      => "\N{U+00BB}",
);

sub 
latextou 
{
	my $str		= shift;

	my $dst		= undef;
	my $magic	= chr(0x0a);	# a str can never come with '\n' so we
					# use it as magical placeholder
	# m!\\\\! expands to m!\\!
	$str =~ s!$esc$esc$esc$esc!$magic!g;
	while (my ($k, $v) = each %latextou) {
		$str =~ s!$esc$esc$k!$v!g;
	}
	$str =~ s!$magic!$esc!g;

	$dst = $str;

	return $dst;
}

# returns the hexdump of a string
sub 
hdump 
{
	my $str 	= shift;
	my $r 		= undef;
	
	$r = "";

	use bytes;
	$r .= sprintf("%x", ord($_)) for split "", $str;
	no bytes;

	return $r;
}

sub
filter_string
{
	my $cmd		= shift;
	my $server	= shift;
	my $win		= shift;

	my ($param, $chan, $msg) = $cmd =~ /^(-\S*\s)?(\S*)\s(.*)/;
	
	# XXX: We should be able to get the $window object someway, this hacks
	# makes /msg #channel \a\a\a
	# return: \a\a\a
	# instead of parsing '\a\a\a' 
	return unless $win and $cmd and $server; # we cannot get all window
			# objects, then do nothing.

	if ($parsed) {
		$parsed = 0;
	} else {
		&Irssi::print("--------------------------------") if $debug;
		if ($debug) {
			&Irssi::print("\$server: $server");
			&Irssi::print("\$msg: $msg");
			&Irssi::print("\$chan: $chan");
			&Irssi::print("\$win: $win");
			&Irssi::print("\$win:". 
			(join ',', (map {"$_ => ". $win->{$_}} keys %$win)));
		}

		&Irssi::print("hdump old \$msg: ". hdump($msg)) if $debug;
		if (not utf8::is_utf8($msg)) {
			&Irssi::print("UTF-8 flag is off!")  if $debug;
			&Encode::_utf8_on($msg);
			&Irssi::print("UTF-8 flag is now on!")  if $debug;
		}
		if (not utf8::is_utf8($msg)) {
			&Irssi::print("UTF-8 flag is still off!")  if $debug;
		}
		&Irssi::print("Mid \$msg: $msg") if $debug;
		&Irssi::print("hdump mid \$msg: ". hdump($msg)) if $debug;
		$msg = latextou($msg);
		&Irssi::print("New \$msg: $msg") if $debug;
		&Irssi::print("hdump new \$msg: ". hdump($msg)) if $debug;
		$parsed = 1;
		&Irssi::signal_emit("command msg", "$chan $msg", $server, $win);
		&Irssi::signal_stop();
	}
}

&Irssi::command_bind('msg', \&filter_string);
