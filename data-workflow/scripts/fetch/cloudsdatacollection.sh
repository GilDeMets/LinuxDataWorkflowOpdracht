#! /bin/bash

#----------Variabelen----------
#------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(realpath "$SCRIPT_DIR/../..")"

DATADIRCLOUDS="$ROOT_DIR/raw/clouds"
LOGFILECLOUDS="$ROOT_DIR/logs/fetch/clouds.log"

timestamp=$(date -u +%Y%m%d-%H%M%S)

outfile="$DATADIRCLOUDS/cloudsdata-${timestamp}.txt"

#----------URL----------
#-----------------------

URLCLOUDS="https://tgftp.nws.noaa.gov/data/observations/metar/stations/EBCV.TXT"

#----------Logs----------
#------------------------

exec 2>> "$LOGFILECLOUDS"

{
        echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] Start data download"
        echo "Tijdstip: $(date -u '+%Y-%m-%d %H:%M')"
} >> "$LOGFILECLOUDS"

if curl -s --show-error "$URLCLOUDS" -o "$outfile" ; then
        echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] Succes: data opgeslagen in $outfile" >> "$LOGFILECLOUDS"
	chmod 444 "$outfile"
else
        echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] Fout: download mislukt" >> "$LOGFILEMETEO"
        rm -f "$outfile"
fi
