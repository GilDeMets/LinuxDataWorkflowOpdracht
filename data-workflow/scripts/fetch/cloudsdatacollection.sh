#! /bin/bash

#----------Variabelen----------
#------------------------------

DATADIRCLOUDS="$HOME/linux-2526-Gil-De-Mets/data-workflow/raw/clouds"
LOGFILECLOUDS="$HOME/linux-2526-Gil-De-Mets/data-workflow/logs/fetch/clouds.log"

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
else
        echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] Fout: download mislukt" >> "$LOGFILEMETEO"
        rm -f "$outfile"
fi
