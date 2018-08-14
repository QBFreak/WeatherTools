#!/usr/bin/perl
use strict;

my $stationFile = 'stations.txt';
my $findCity = "MONROE";
my $findState = "NC";

open F, $stationFile or die("$! $stationFile");

my $line = "";
# Skip the comments and blank lines at the top
while(<F> =~ m/(^!)|(^$)/) {}

# In the middle of all this, we lose a line (right now $line is the Alaska
#   state heading). The thing is, we just honestly don't care about the line we
#   lose. When we read a new line, it's going to be a header row, and we'll
#   toss that out too.

my $count = 0;
while($line = <F>) {
	chomp $line;
	$count ++;
        if (length($line) < 83 ) { next; } # Ignore lines that aren't long enough (headers, first line of a new state)
        my ($state, $station, $ICAO, $IATA, $SYNOP, $LAT, $LONG, $elevation, $METAR, $NEXRAD, $avation, $upperAir, $auto, $office, $priority, $country) =
            unpack("A2xA16xA5xA5xA6xA7xA7xA6xA2xA2xA2xA2xA2xA1xA1xA2", $line);

        if($state eq $findState and $station eq $findCity) {

            print("$count - $line\n");
            print("
STATE:   $state
STATION: $station
ICAO:    $ICAO
IATA:    $IATA
SYNOP:   $SYNOP
LAT:     $LAT
LONG:    $LONG
Elev:    $elevation
METAR:   $METAR
NEXRAD:  $NEXRAD
Avation: $avation
Upperair:$upperAir
Auto:    $auto
Office:  $office
Pri:     $priority
Country: $country\n");

        }
}

close F;
