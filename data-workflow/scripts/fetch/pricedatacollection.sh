#! /bin/bash

#----------Variabelen----------
#------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(realpath "$SCRIPT_DIR/..")"

DATADIRELIA="$ROOT_DIR/raw/price"
LOGFILEELIA="$ROOT_DIR/logs/fetch/price.log"
LIMIT=60

start=$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S)
end=$(date -u +%Y-%m-%dT%H:%M:%S)
timestamp=$(date -u +%Y%m%d-%H%M%S)

outfile="$DATADIRELIA/pricedata-${timestamp}.json"

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
	chmod 444 "$outfile"
else
	echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] Fout: download mislukt" >> "$LOGFILEELIA"
	rm -f "$outfile"
fi
