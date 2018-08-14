#!/bin/bash
STATIONFILE=stations.txt

function thirdWord {
	if [ -z $3 ]; then
		echo "NOTFOUND"
	else
		echo $1 $2 $3
	fi
}

if [[ -z $1 || -z $2 ]]; then
	echo "BADPARAM"
	exit
fi

pushd `dirname $0` >/dev/null

if [ -s $STATIONFILE ]; then
	thirdWord `grep -i "$2 $1" $STATIONFILE`
else
	echo "NOSTATIONS"
fi

popd >/dev/null
