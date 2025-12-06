#! /bin/bash

#----------Variabelen----------
#------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(realpath "$SCRIPT_DIR/..")"

CLOUDSDIR="$ROOT_DIR/raw/clouds"
SOLARDIR="$ROOT_DIR/raw/solar"
RADIATIONDIR="$ROOT_DIR/raw/radiation"
PRICEDIR="$ROOT_DIR/raw/price"

OUTDIR="$ROOT_DIR/processed"

LOGFILE="$ROOT_DIR/logs/transform.log"

#----------Alles opvangen----------
#----------------------------------

exec 1>>"$LOGFILE"
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

rm "$OUTDIR/clouds15.csv"

for f in "$CLOUDSDIR"/*.txt; do
	echo "PROCESSING $f" >&2

	metar=$(sed -n '2p' "$f")

	z=$(echo "$metar" | grep -o '[0-9]\{6\}Z' | head -n1)

	if [[ -n "$z" ]]; then
    		day=${z:0:2}
    		hour=${z:2:2}
    		min=${z:4:2}
	else
    		echo "No METAR timestamp in $f" >&2
   	continue
	fi

	raw_date=$(head -n1 "$f" | tr -d '\r')
	ym=$(echo "$raw_date" | awk '{print $1}' | cut -d'/' -f1-2 | tr '/' '-')

	timestamp=$(date -d "$ym-$day $hour:$min" "+%Y-%m-%dT%H:%-M")
	timestamp=$(echo "$timestamp" | tr -d '\r')
	metar=$(sed -n '2p' "$f")

	layers=$(echo "$metar" | grep -oE "(FEW|SCT|BKN|OVC)([0-9/]{3}|///)")

	maxokta=0
	for l in $layers; do
		okta=$(cloud2okta "$l")
		if (( okta > maxokta )); then
			maxokta=$okta
		fi
	done

	minuten=$((10#$min))

	if (( minuten<30 )); then
		roundedtime="00"
	else
		roundedtime="30"
	fi

	basetime=$(date -d "$ym-$day $hour:$roundedtime" +%s)

	block1=$(date -d "@$basetime" +"%Y-%m-%dT%H:%M")

	block2base=$(( basetime + 15 * 60 ))
	block2=$(date -d "@$block2base" +"%Y-%m-%dT%H:%M")
	
	echo "$block1,$maxokta" >> "$OUTDIR/clouds15.csv"
	echo "$block2,$maxokta" >> "$OUTDIR/clouds15.csv"
	echo "DONE PROCESSING $f" >&2
done

sort -t',' -k1,1 "$OUTDIR/clouds15.csv" -o "$OUTDIR/clouds15.csv"

#----------Price----------
#-------------------------

rm "$OUTDIR/price15.csv"

for f in "$PRICEDIR"/*.json; do
	echo "PROCESSING $f" >&2
	
	jq -r '
	.results
	| group_by(.quarterhour)
	| map({
		quarterhour: 
			(.[0].quarterhour
				| strptime("%Y-%m-%dT%H:%M:%S%z")
				| mktime + 3600
				| strftime("%Y-%m-%dT%H:%M")),
		avg: 
			(map(
				.imbalanceprice)
				| add / length)
	})
	| .[]
	| "\(.quarterhour),\(.avg)"
	' "$f" >> "$OUTDIR/price15.csv"

	echo "DONE PROCESSING $f" >&2
done

sort -t',' -k1,1 "$OUTDIR/price15.csv" -o "$OUTDIR/price15.csv"

#----------Radiation----------
#-----------------------------

rm "$OUTDIR/radiation15.csv"

for f in "$RADIATIONDIR"/*.json; do
	echo "PROCESSING $f" >&2

	rawdate=$(basename "$f" | cut -d'-' -f2) 
	date="${rawdate:0:4}-${rawdate:4:2}-${rawdate:6:2}"

	jq -r --arg d "$date" '
	.minutely_15
	| [ .time, .shortwave_radiation ]
	| transpose
	| map(select(.[0] | startswith($d)))
	| map("\(.[0]),\(.[1])")
	| .[]
	' "$f" >> "$OUTDIR/radiation15.csv"

	echo "DONE PROCESSING $f" >&2
done

sort -t',' -k1,1 "$OUTDIR/radiation15.csv" -o "$OUTDIR/radiation15.csv"

#----------Solar----------
#-------------------------

rm "$OUTDIR/solar15.csv"

for f in "$SOLARDIR"/*.csv; do
	echo "PROCESSING $f" >&2

	rawdate=$(basename "$f" | cut -d'-' -f2)
	date="${rawdate:0:4}-${rawdate:4:2}-${rawdate:6:2}"

	sed -n '/^"Periode";"Vermogen \[W\]"/,$p' "$f" \
 	| tail -n +2 \
  	| awk -F';' -v d="$date" '
      	BEGIN {
      		gsub(/\./,"",FS)
		block_sum = 0
		block_idx = 0
      	}

      	function block_minute(m) {
    		if (m==5  || m==10 || m==15) return 15
    		if (m==20 || m==25 || m==30) return 30
    		if (m==35 || m==40 || m==45) return 45
    		if (m==50 || m==55 || m==0)  return 0
    		return m
	}

  	{
        	gsub(/"/, "", $1)
         	gsub(/"/, "", $2)

         	time=$1
         	power=$2

         	gsub(/\./, "", power)

		block_sum += power
		block_idx++

		if (block_idx == 3) {
			split(time, t, ":")
			h = t[1] + 0
			minute = t[2] + 0

			block = block_minute(minute)

			if (minute == 0) {
				h = (h + 1) % 24
			}
			
		timestamp = sprintf("%sT%02d:%02d", d, h, block)

         	print timestamp "," block_sum

         	block_sum = 0
         	block_idx = 0

         	}
      	}' >> "$OUTDIR/solar15.csv"

	echo "DONE PROCESSING $f" >&2
done

echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] ALL DATA TRANSFORMED TO 15 MIN INTERVAL CSV" >&2

#----------Alles in 1 file----------
#-----------------------------------

echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] START COMBINING DATA" >&2

rm "$OUTDIR/combined.csv"

files=(
	"$OUTDIR"/clouds15.csv
	"$OUTDIR"/price15.csv
	"$OUTDIR"/radiation15.csv
	"$OUTDIR"/solar15.csv
)

echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] CREATING MASTER TIMESTAMP" >&2
mastertimestamp=$(mktemp)
sortedtimestamps=$(mktemp)

for f in "${files[@]}"; do
	cut -d',' -f1 "$f" >> "$mastertimestamp"
done

sort -u "$mastertimestamp" > "$sortedtimestamps"

echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] DONE CREATING MASTER TIMESTAMP" >&2
echo "BEGIN COMBINING" >&2

awk -F',' '
	BEGIN {
		for(i=2;i<ARGC;i++){
			f=ARGV[i]
			if (f ~ /clouds/)    tag[f]="clouds"
			if (f ~ /price/)     tag[f]="price"
			if (f ~ /radiation/) tag[f]="radiation"
			if (f ~ /solar/)     tag[f]="solar"
		}
	}

	FNR==NR {
		timeline[$1] = 1
		next
	}

	{
		ts=$1
       		val=$2

		if (tag[FILENAME] == "clouds")    clouds[ts]=val
        	if (tag[FILENAME] == "price")     price[ts]=val
        	if (tag[FILENAME] == "radiation") radiation[ts]=val
        	if (tag[FILENAME] == "solar")     solar[ts]=val
    	}

	END {
        	print "timestamp,clouds,price,radiation,solar"

        	for (ts in timeline) {
            		t = ts
            		c = (t in clouds)    ? clouds[t]    : "NA"
            		p = (t in price)     ? price[t]     : "NA"
		        r = (t in radiation) ? radiation[t] : "NA"
	            	s = (t in solar)     ? solar[t]     : "NA"
	            	print t "," c "," p "," r "," s
        	}
    	}
	' "$sortedtimestamps" "${files[@]}" > "$OUTDIR/combined.csv"

rm "$mastertimestamp" "$sortedtimestamps"

{ head -n 1 "$OUTDIR/combined.csv"; tail -n +2 "$OUTDIR/combined.csv" | sort -t',' -k1,1; } \
 > "$OUTDIR/combined.tmp" && mv "$OUTDIR/combined.tmp" "$OUTDIR/combined.csv"

echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] DONE COMBINING DATA INTO COMBINED.CSV" >&2
