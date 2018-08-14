#!/usr/bin/perl
use lib qw(lib);

use Geo::METAR;
use strict;

my $m = new Geo::METAR;
#$m->metar("KFDY 251450Z 21012G21KT 8SM OVC065 04/M01 A3010 RMK 57014");
$m->metar("@ARGV");
#print $m->dump;

#my $cond;
#my @sky = $m->SKY;

#print "\n\n";

if ($m->TYPE) {	print $m->TYPE; } else { print "Weather"; }
if ($m->site) {	print " for ", $m->SITE; }
if ($m->TIME) { print " at ", $m->TIME; }
print ": ";
if ($m->TEMP_F) { print "Current temp is ", $m->TEMP_F, " degrees"; }
if ($m->TEMP_F && $m->DEW_F)
	{ print " and the";}
elsif ($m->DEW_F)
	{ print ". The"; }
elsif ($m->TEMP_F)
	{ print ". "; }
if ($m->DEW_F) { print " dewpoint is ", $m->DEW_F, " degrees."; }
if ($m->ALT) { print " The barometer is ", $m->ALT, "in."; }
if ($m->WIND_MPH && $m->WIND_DIR_ENG && $m->WIND_MPH) {
	print " Winds are blowing ";
	print $m->WIND_DIR_ENG, " at ";
	print $m->WIND_MPH, " MPH";
	if ($m->WIND_GUST_MPH)
		{ print ", gusting to ", $m->WIND_GUST_MPH; }
	else
		{ print "."; }
}
#print ". Current sky conditions are ";
#foreach $cond (@sky) {
#	print "$cond ";
#}
if ($m->visibility) { print " Current visibility is ", $m->VISIBILITY, ". "; }
print "\n";

#print "DEBUG: ", $m->site, "\n";
#print "DEBUG: ", $m->SITE, "\n";

exit;
