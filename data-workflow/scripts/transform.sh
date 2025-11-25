#! /bin/bash
set -euo pipefail

#----------Variabelen----------
#------------------------------

CLOUDSDIR="$HOME/linux-2526-Gil-De-Mets/data-workflow/raw/clouds"
SOLARDIR="$HOME/linux-2526-Gil-De-Mets/data-workflow/raw/solar"
RADIATIONDIR="$HOME/linux-2526-Gil-De-Mets/data-workflow/raw/radiation"
PRICEDIR="$HOME/linux-2526-Gil-De-Mets/data-workflow/raw/price"

OUTDIR="$HOME/linux-2526-Gil-De-Mets/data-workflow/processed"

LOGFILE="$HOME/linux-2526-Gil-De-Mets/data-workflow/logs/transform.log"

#----------Alles opvangen----------
#----------------------------------

exec 1>/dev/null
exec 2>>"$LOGFILE"

echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] Start transformeren data naar .csv" >&2

#----------Clouds----------
#--------------------------

cloud2okta() {
	case "$1" in
		FEW*) echo 2 ;;
		SCT*) echo 4 ;;
		BKN*) echo 7 ;;
		OVC*) echo 8 ;;
		*)    echo 0 ;;
	esac
}

> "$OUTDIR/clouds15.csv"

for f in "$CLOUDSDIR"/*.txt; do
	echo "PROCESSING $f" >&2

	date=$(head -n1 "$f" | tr -d '\r')
	cleandate=$(echo "$date" | cut -d' ' -f1 | tr '/' '-')
	timestamp=$(date -d "$cleandate" +"%Y-%m-%dT%H:%M")

	metar=$(sed -n '2p' "$f")

	layers=$(echo "$metar" | grep -oE "(FEW|SCT|BKN|OVC)([0-9/]{3}|///)")

	maxokta=0
	for l in $layers; do
		okta=$(cloud2okta "$l")
		if (( okta > maxokta )); then
			maxokta=$okta
		fi
	done

	uur=${timestamp:11:2}
	minuten=${timestamp:14:2}

	if (( minuten<30 )); then
		afgerondetijd="00"
	else
		afgerondetijd="30"
	fi

	blok1="${timestamp:0:14}$afgerondetijd"
	blok2=$(date -d "$blok1 + 15 minutes" +"%Y-%m-%dT%H:%M")

	echo "$blok1,$maxokta" >> "$OUTDIR/clouds15.csv"
	echo "$blok2,$maxokta" >> "$OUTDIR/clouds15.csv"
done

sort -t',' -k1,1 "$OUTDIR/clouds15.csv" -o "$OUTDIR/clouds15.csv"
