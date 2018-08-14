#!/bin/bash
STATIONFILE=stations.txt
#BASEURL=http://weather.noaa.gov/pub/data/observations/metar/cycles/
BASEURL=http://tgftp.nws.noaa.gov/data/observations/metar/cycles/
TEMPFILE=.bot.weather.temp

if [ -z $1 ]; then
	echo "BADSTATION"
	exit
fi

function thirdWord {
	if [ -z $3 ]; then
		echo "NOSTATION"
		exit
	else
		echo $3
	fi
}

function locdata {
	STATE=$1
	CITY=$2
	ICAO=$3
}

HOUR=`date -u +%H`

let LASTHOUR=`printf '%g' $HOUR`-1

if [ "$LASTHOUR" -lt 0 ]; then
	LASTHOUR=23
fi

CYCLE=`printf "%02g%s" $HOUR Z`
LASTCYCLE=`printf "%02g%s" $LASTHOUR Z`
EXPIREFILE=.bot.$CYCLE.expire
LASTEXPIREFILE=.bot.$LASTCYCLE.expire

CYCLEFILE=$CYCLE.TXT
LASTCYCLEFILE=$LASTCYCLE.TXT

pushd `dirname $0` >/dev/null

#ICAO=`icao $1 $2`
locdata `grep "$1" $STATIONFILE`
if [ -z "$ICAO" ]; then
	echo "BADSTATION"
	exit
fi

if [[ ! -e "$CYCLEFILE" || ! -e "$EXPIREFILE" || "`date +%s`" -gt "`cat $EXPIREFILE`" ]]; then
	if [ -e $CYCLEFILE ]; then
		rm $CYCLEFILE
	fi
        let EXPIRETIME=`date +%s`+300
	echo $EXPIRETIME > $EXPIREFILE
	wget -q $BASEURL$CYCLEFILE
fi

if [[ ! -e "$LASTCYCLEFILE" || ! -e "$LASTEXPIREFILE" || "`date +%s`" -gt "`cat $LASTEXPIREFILE`" ]]; then
	if [ -e $LASTCYCLEFILE ]; then
		rm $LASTCYCLEFILE
	fi
        let LASTEXPIRETIME=`date +%s`+300
	echo $LASTEXPIRETIME > $LASTEXPIREFILE
	wget -q $BASEURL$LASTCYCLEFILE
fi

if [ -e $TEMPFILE ]; then
	rm $TEMPFILE
fi

if [ -e $CYCLEFILE ]; then
	cat $CYCLEFILE > $TEMPFILE
fi
if [ -e $LASTCYCLEFILE ]; then
	cat $LASTCYCLEFILE >> $TEMPFILE
fi

if [ -s $TEMPFILE ]; then
	DATA=`grep -i "$ICAO" $TEMPFILE | head -n 1`
	if [ "$DATA" == "" ]; then
		echo "NODATA"
	else
		if [[ -z "$CITY" || -z "$STATE" ]]; then
			./metar2eng.pl $DATA
		else
			#echo "DEBUG: ./metar2eng.pl $DATA \| sed s/\"$ICAO\"/\"$CITY, $STATE\"/g"
			./metar2eng.pl $DATA | sed s/"$ICAO"/"$CITY, $STATE"/g
		fi
	fi
else
	echo "NODATA"
	if [ -e $CYCLEFILE ]; then
		rm $CYCLEFILE
	fi
fi

popd >/dev/null
