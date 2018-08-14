# Weather tools

This is a collection of scripts I've slowly hacked together over the years for working with NOAA weather data.
Some of them are pretty terribly written, but I just wanted to dump the whole mess to a repo before I lost it.

## getall.pl

This is actually the culmination of most of the other things I've worked out.
It is also the worst-named.
It takes an ICAO location indicator (hardcoded near the top) and will download the last 24 hours of weather reports and graph the barometric pressure history for that duration.
The output is generated in the form of `ICAO.png`.
Be warned that this will download 24 weather history files in the current directory, however subsequent runs will only download as many as are needed to bring the data set up to date.

![Sample Barometric Pressure history graph](https://raw.githubusercontent.com/QBFreak/WeatherTools/master/KEQY.png)

## geticao.pl

Look up an ICAO location indicator in `stations.txt` based on the hardcoded city and state.
This is a much more robust version of `geticao.sh`.

## geticao.sh

Look up an ICAO location indicator in `stations.txt` as specified on the command line.

*Usage:* `./geticao.sh <City> <ST>`

*Example:*
```$ ./geticao.sh Monroe NC
NC MONROE KEQY
```

Cannot handle locations with spaces in the name, which is why `geticao.pl` was written.

## getweathericao.sh

Retrieve the weather for a given ICAO location indicator as specified on the command line.

*Usage:* `./getweathericao.sh <ICAO>`

*Example:*
```$ ./getweathericao.sh KEQY
Routine Weather Report for MONROE, NC at 23:53 UTC: Current temp is 80.6 degrees and the dewpoint is 68.0 degrees. The barometer is 29.97in. Current visibility is 10 Statute Miles.
```

Uses `metar2eng.pl` to decode the weather report into plain English.
This was written for a chat bot on a MUD long ago.

This uses the same flawed method as `geticao.sh` to look up the City and State name for the ICAO, and thus a city name with one or more spaces is going to fail as the City/State lookup overwrites the ICAO with the second word of the city name, and that will fail the weather data lookup by ICAO.

## getweatherloc.sh

Retrieve the weather for a given City, State as specified on the command line.

*Usage:* `./getweatherloc.sh <CITY> <ST>`

*Example:*
```$ ./getweatherloc.sh Monroe NC
Routine Weather Report for MONROE, NC at 23:53 UTC: Current temp is 80.6 degrees and the dewpoint is 68.0 degrees. The barometer is 29.97in. Current visibility is 10 Statute Miles.
```

All of the issues `getweathericao.sh` has with spaces, this does too.

## metar2eng.pl

Translate a METAR weather report into plain English.

*Usage:* `./metar2eng.pl <METAR>`

*Example:*
```$ ./metar2eng.pl KEQY 132353Z AUTO 00000KT 10SM CLR 27/20 A2997 RMK AO2 SLP147 T02670200 10306 20267 55001
Routine Weather Report for KEQY at 23:53 UTC: Current temp is 80.6 degrees and the dewpoint is 68.0 degrees. The barometer is 29.97in. Current visibility is 10 Statute Miles.
```

## stations.TXT

A list of weather stations by ICAO location indicator.
*Please don't use this one in production. Get the latest:* http://www.rap.ucar.edu/weather/surface/stations.txt
The only reason I'm including one in the repo, is so that when you try things out, they just _work._
It's quite outdated at the time I included it.
