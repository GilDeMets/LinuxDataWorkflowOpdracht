#! /bin/bash

#----------Variabelen----------
#------------------------------

DATADIRELIA="$HOME/linux-2526-Gil-De-Mets/data-workflow/raw/price"
LOGFILEELIA="$HOME/linux-2526-Gil-De-Mets/data-workflow/logs/fetch/elia.log"
LIMIT=60

start=$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S)
end=$(date -u +%Y-%m-%dT%H:%M:%S)
timestamp=$(date -u +%Y%m%d-%H%M%S)

outfile="$DATADIRELIA/eliadata-${timestamp}.json"

#----------API-call----------
#----------------------------

URL="https://opendata.elia.be/api/explore/v2.1/catalog/datasets/ods161/records?where=datetime%20%3E%3D%20'$start'%20AND%20datetime%20%3C%20'$end'&order_by=datetime%20ASC&limit=${LIMIT}"

#----------Logs----------
#------------------------

exec 2>> "$LOGFILEELIA"

{
	echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] Start data download"
	echo "Periode: $start -> $end"
} >> "$LOGFILEELIA"

if curl -s --show-error -X GET "$URL" -o "$outfile" ; then
	echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] Succes: data opgeslagen in $outfile" >> "$LOGFILEELIA"
else
	echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] Fout: download mislukt" >> "$LOGFILEELIA"
	rm -f "$outfile"
fi
