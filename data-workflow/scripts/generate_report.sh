#! /bin/bash

#----------Variabelen----------
#------------------------------

GRAFIEKENDIR="$HOME/linux-2526-Gil-De-Mets/data-workflow/analysis-output"
GRAFIEKENTOTAL="$GRAFIEKENDIR/total"
GRAFIEKENTODAY="$GRAFIEKENDIR/today"

CSVDIR="$HOME/linux-2526-Gil-De-Mets/data-workflow/processed"
CSVFILE="$CSVDIR/combined.csv"

REPORTDIR="$HOME/linux-2526-Gil-De-Mets/data-workflow/report"
HISTORYDIR="$REPORTDIR/history"

LOGFILE="$HOME/linux-2526-Gil-De-Mets/data-workflow/logs/generate_report.log"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
FILESTAMP=$(date +"%Y-%m-%d")

TEMPLATE="$REPORTDIR/template.md"
REPORT_MD="$REPORTDIR/report_$FILESTAMP.md"
REPORT_PDF="$REPORTDIR/report_$FILESTAMP.pdf"

#----------Logging----------
#---------------------------

exec 1>>"$LOGFILE"
exec 2>>"$LOGFILE"

echo "[$TIMESTAMP] Start met genereren rapport" >&2

#----------Grafieken----------
#-----------------------------

echo "Start genereren grafieken"

FIGURES_TOTAL=""

for fig in "$GRAFIEKENTOTAL"/*.png; do 
	if [[ -f  "$fig" ]]; then
		rel="../analysis-output/total/${fig##*/}"
		FIGURES_TOTAL+="![${fig##*/}](${rel})\n\n"
	fi
done

FIGURES_TODAY=""

for fig in "$GRAFIEKENTODAY"/*.png; do
	if [[ -f "$fig" ]]; then
		rel="../analysis-output/today/${fig##*/}"
		FIGURES_TODAY+="![${fig##*/}](${rel})\n\n"
	fi
done

echo "Einde genereren grafieken"

#----------Tabel----------
#-------------------------

echo "Start genereren tabel"

TABLES=""


if [[ -f "$CSVFILE" ]]; then
	tmpcsv=$(mktemp)
	tmptable=$(mktemp)
	tail -n 96 "$CSVFILE" > "$tmpcsv"

	awk -F, 'BEGIN{
		print "|Timestamp|Clouds(okta)|Price|Radiation|Solar|"
		print "|---|---|---|---|---|"
		}
		{
		if ($0 ~ /NA/) {
			next
		}

		printf "|%s|%s|%s|%s|%s|\n", $1,$2,$3,$4,$5
		}' "$tmpcsv" > "$tmptable"

	TABLES+="$(cat "$tmptable")"

  	rm "$tmpcsv"
else
    	TABLES="(CSV-bestand niet gevonden: $CSVFILE)\n"
fi

echo "Einde genereren tabel"

#---------Template vullen----------
#----------------------------------

echo "Start genereren md-file"

tmpfile=$(mktemp)
printf "%s\n" "$TABLES" > "$tmpfile"

sed \
	-e "s^{{timestamp}}^$TIMESTAMP^g" \
	-e "s^{{figures_total}}^$FIGURES_TOTAL^g" \
	-e "s^{{figures_today}}^$FIGURES_TODAY^g" \
	"$TEMPLATE" | \
	sed "/{{table_section}}/ {
		r $tmpfile
		d
	}" \
	> "$REPORT_MD"
rm "$tmpfile"

echo "Einde genereren md-file"







