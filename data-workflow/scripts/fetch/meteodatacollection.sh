#! /bin/bash

#----------Variabelen----------
#------------------------------

DATADIRMETEO="$HOME/linux-2526-Gil-De-Mets/data-workflow/raw/radiation"
LOGFILEMETEO="$HOME/linux-2526-Gil-De-Mets/data-workflow/logs/fetch/radiation.log"

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

if curl -s -X GET "$URLMETEO" -o "$outfile" ; then
	echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] Succes: data opgeslagen in $outfile" >> "$LOGFILEMETEO"
else
	echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] Fout: download mislukt" >> "$LOGFILEMETEO"
	rm -f "$outfile"
fi
