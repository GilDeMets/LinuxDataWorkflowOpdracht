#! /bin/bash

#----------Variabelen----------
#------------------------------

SCRIPT_DIR="$(cd "$(dirnamme "$0")" && pwd)"
ROOT_DIR="$(realpath "$SCRIPT_DIR/..")"

DATADIRMETEO="$ROOT_DIR/raw/radiation"
LOGFILEMETEO="$ROOT_DIR/logs/fetch/radiation.log"

timestamp=$(date -u +%Y%m%d-%H%M%S)

outfile="$DATADIRMETEO/radiationdata-${timestamp}.json"

#----------API-call----------
#----------------------------

URLMETEO="https://api.open-meteo.com/v1/forecast?latitude=50.86&longitude=3.61&minutely_15=shortwave_radiation&timezone=Europe%2FBrussels"

#----------Logs----------
#------------------------

exec 2>> "$LOGFILEMETEO"

{
	echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] Start data download"
	echo "Periode: $(date -u '+%Y-%m-%d') -> $(date -u -d '2 days' '+%Y-%m-%d')"
} >> "$LOGFILEMETEO"

if curl -s --show-error -X GET "$URLMETEO" -o "$outfile" ; then
	echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] Succes: data opgeslagen in $outfile" >> "$LOGFILEMETEO"
	chmod 444 "$outfile"
else
	echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] Fout: download mislukt" >> "$LOGFILEMETEO"
	rm -f "$outfile"
fi
