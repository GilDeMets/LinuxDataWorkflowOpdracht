#README

## Data collectie

### Ophalen data

#### Clouds

> Hier haal ik de METAR data over de bewolking boven het vliegveld van Chievres in Henegouwen. Ik heb voor deze luchthaven gekozen omdat dit de dichtste is bij mij thuis. Ik heb hiervoor gekozen om te kijken bij welk soort bewolking ik effectief minder energie produceer. Deze data wordt om het half uur ge-update of vaker indien er een grote weersverandering is. Elk half uur is voldoende voor mijn case.  
> Deze data wordt in plain text verkregen en deze verwerk ik dan mee tot de csv. Aangezien de data een simpel txt document is, gebruik ik gewoon een simpele `curl` die de data opslaat in de `raw/clouds` directory. Alle errors of messages worden opgeslagen in een logsfile. De rauwe data wordt read-only gemaakt ook in het script.  
> De eerste weken haalde ik de data automatisch op met een lijntje in mijn crontab. Elk half uur. Deze crontab vindt u ook terug in de directory onder `cron/crontab.txt`. De laatste dag van de opdracht heb ik nog github actions opgezet en werd de data zo opgehaald. Dit ook elk half uur.
 
#### Price

> Hier haal ik de prijs van energie in Belgie op per minuut. Dit om een zo accuraat mogelijke prijsbepaling te hebben. Deze wordt opgehaald via een API-call en komt binnen als JSON.   
> Ook hier maak ik gebruik van een `curl -X GET` om de data op te slaan in zijn eigen directory: `raw/price`. Ook hier wordt alles gelogd in een logfile en wordt de data read-only gemaakt.  
> De data wordt elk uur opgehaald omdat elia het aantal regels per API-call limiteert tot 100. Maar 60 lijnen bezorgt mij net een uur en die data lijkt mij gemakkelijker te verwerken. Ook hier gebruikte ik de crontab eerst en de laatste dag github actions. Voor price en clouds heb ik elk een aparte workflow opgezet in de actions.

#### Radiation

> Hier haal ik binnen hoeveel zonnestralen of radiation er doorkomen op de coordinaten van mijn huis. Dit wordt ook via een API-call binnen gehaald met curl. Met deze data en de gegevens van mijn installatie kan ik dan berekenen hoeveel mijn zonnepanelen zouden moeten opbrengen. De data komt binnen als JSON.  
> Ook hier `curl -X GET` met een eigen directory: `raw/radiation`. Alles wordt gelogd en de data wordt read-only gemaakt.  
> Hier brengt de API-call data binnen van 24u voor de call tot 48u na de call. Omdat ik geen voorspelling wil doen maar analyse, haal ik eenmaal per dag de data binnen. Eerst via de crontab, daarna via github actions.
 
#### Solar

> Hier haal ik de data van mijn eigen installatie binnen. Dit wordt jammer genoeg met een python-script gedaan omdat ik geen manier vond om de data gratis binnen te halen. De API-call kost geld en de data is enorm goed beveiligd waardoor ik ze niet gescrapet krijg. Ik probeerde headless windows, html scraping, ik probeerde zelfs lokaal via het ip van mijn omvormer aan de data te komen, maar helaas. Vandaar het python-script. Dit script download rechtstreeks van de pagina een csv-bestand dat ik daarna nog verwerk voor in mijn eigen CSV- bestand.  
> Het script brengt ons naar de site, logt in, klikt de cookiebanner weg, klikt enkele veldjes open en drukt op een download csv knop. Deze data wordt dan ook in zijn eigen mapje `raw/solar` opgeslagen. Dit python script vangt ook de logs op en slaat ze op onder `logs/fetch/solar.log`. De data wordt dan read-only gemaakt.  
> Deze csv bevat dat van de huidige dag in stapjes van aantal watt geproduceerd per 5 min. Opgehaald met de crontab eerst, wat wel wat lastiger was vanwege het wachtwoord en de virtual environment. Maar toch gelukt en daarna ook via github actions.

### Periode

> * Clouds: 19/11/2025 22:15 - ~ 02/12/2025 en laatste weekend 5-7/12; elk half uur
> * Price: 19/11/2025 22:15 - ~ 02/12/2025 en laatste weekend; elk uur
> * Radiation: 19/11/2025 22:15 - ~ 02/12/2025 en laatste weekend; eenmaal per dag, 23:55
> * Solar: 19/11/2025 22:15 - ~ 02/12/2025 en laatste weekend; eenmaal per dag, 23:55

> Opmerking: Ik kan dit enkel lokaal op mijn laptop draaien, ik heb deze elk mogelijk moment laten aanstaan met de VM open, maar er zijn natuurlijk gaten als ik naar school en terug naar huis verplaats. Ook crashte mijn VM soms indien mijn laptop zich op een ander scherm begaf.  
> Het laatste weekend werd alles opgehaald met github actions, dus dat probleem was opgelost.

## Data transformeren

> Alle data wordt getransformeerd naar csv met komma notatie in 1 script: `scripts/transform.sh`. Ik zal het script stap voor stap uitleggen en overlopen.
> * Variabelen aanmaken met alle directories die we nodig hebben, alsook een logfile.
> * Alle logs worden opgevangen in de logfile `logs/transform.log`
> * Transformeren clouds data met eerste een functie die de METAR tekst omzet in de okta-schaal die bepaald hoeveel wolken er zich in de lucht bevinden. Dit is een cijferschaal die gemakkelijker gebruikt kan worden in analyse. We overlopen alle bestanden met een for-loop. Eerst halen we de timestamp met `sed` uit de data, dit dmv de zulu tijd. De tijdsmeting wordt ook gelogd in de data, maar bij het gebruik van deze liep het script telkens vast door fouten in de data. De zulu-waarde is altijd correct. Dan nemen we de juiste tekst voor de wolken uit het bestandje met `grep` en overlopen deze. Soms kunnen er meerdere getallen zijn voor de verschillende wolkenlagen. Ik opteerde voor de hoogste okta-waarde te behouden, ofwel het meeste aantal wolken. Dan moest ik nog tijd afronden naar elke 15 minuten om overeen te komen met de andere data. Dit allemaal wordt in `processed/clouds15.csv` gestoken.
> * Transformeren price data: elke file overlopen met for-loop en een `jq` die filtert op `.results`, groepeert per 15 minuten en dan de gemiddelde imbalanceprice er uit haalt. Dit alles komt in de file `processed/price15.csv`.
> * Transformeren radiation data: Gelijkaardig aan de price, filteren op 15 minuten eerst, dan de juiste radiation er uit halen en mappen op de datum dat ik enkel vandaag er uit haal en niet alle 3 de dagen. Ook dit krijgt zijn eigen csv: `processed/radiation15.csv`.
> * Dan de solar data nog: ook hier met een for-loop alle bestanden overlopen. Filter de header er uit, dan met `awk` blokjes maken van 15 min, daarin de 3 stukjes vermogen optellen. Het commando in het script ziet er ingewikkelder uit dan het is. Ook dit krijgt zijn eigen csv: `processed/solar15.csv`
> * Als laatste worden al deze aparte csv's gecombineerd tot 1 file `processed/combined.csv`. Een master timestamp wordt gemaakt waarin alle timestamps van alle files staan. Dus als ergens een timestamp niet bestaat, wordt ze toch gebruikt door de andere files. Met `awk` combineer ik dan de files. Als er data ontbreekt, wordt er 'NA' ingevuld. 

## Data analyse

> Voor deze heb ik een python-script laten generen dat mij enkele logische grafieken geeft en enkele scatter-plots voor de totale data en voor de data van de laatste 24u. Al deze grafieken worden opgeslagen in `analysis-output`. Hier heb ik by far het minste tijd aan gespendeerd. 

## Rapport genereren

> Hierin wordt een rapport gegenereerd. Eerst in markdown, dan pdf en daarna een reveal.js presentatie.
> * Eerst opnieuw variabelen met alle directories en nodige files.
> * Logging wegschrijven naar `logs/generate_report.log`
> * De grafieken die uit de vorige stap halen we 1 voor 1 op en steken we in een string met de totale data en een string met de data van afgelopen 24u. 
> * Genereren van een markdown tabel met `awk`
> * Vullen van de template dmv `sed` te gebruiken om placeholders in `report/template.md` te vervangen.
> * Genereren van een pdf-file met `pandoc` na het verwijderen van elke markdown en pdf file uit `report`. Na het genereren plaatsen we de pdf in `report` en maken we meteen een kopie in `report/history` om de pdf te archiveren.
> * Genereren van een reveal.js presentatie. Met enkele `sed` commando's wat zaken verwijderen en bijvoegen in onze markdown en dan met `awk` de titels vervangen zodat elke slide 1 grafiek heeft. De opbouw van de presentatie is niet 100% in orde omdat ik niet genoeg tijd had om dit nog allemaal te fixen. Als ik hier nog langer aan had kunnen werken was dit zeker goed gekomen.

## Automatiseren

> Voor het automatiseren opteerde ik voor github actions. Ik maakte 3 workflows die te vinden zijn in `github-actions`
> * clouds.yml loopt elk half uur en haalt enkel de data op voor de wolken.
> * price.yml loopt elk uur en haalt enkel de data op voor de prijs.
> * daily.yml loopt elke dag om 23:55. Hierin installeer ik alle dependencies uit `requirements.txt` en deze verder in deze file te vinden. De python dependencies staan ook gecached in de github actions. Na het installeren van de dependencies wordt `scripts/fetch/radiationdatacollection.sh` eerste uitgevoerd en daarna `scripts/fetch/solardatacollection.sh`. Het wachtwoord is opgeslaan in een secret in de github repo. Na het ophalen wordt het `scripts/transform.sh`, het `script/analyze.py` en het `script/generate_report.sh` gerunned. Alles wordt dan gepushed naar de repo. 

## Structuur directories

> * `analysis-output`: alle png's uit analyse script
> * `cron`: de crontab die ik gebruikte voor github actions
> * `github-actions`: kopies van YAMLs voor github actions, de oorspronkelijke moeten buiten de `data-workflow` directory staan om te kunnen runnen.
> * `logs`: logfiles + subdirectory `fetch` met fetch logs
> * `processed`: geproceste data in csv
> * `raw`: aparte directory voor elke soort. Alle files read-only
> * `report`: `template.md`, report van dag voordien in markdown, pdf en presentatie + een history directory met gearchiveerde pdf's
> * `scripts`: alle scripts
> * `requirements.txt`: de python dependencies (nodig voor github actions caching)
> * `README.md`: deze file

## install dependencies

- `sudo apt-get update`
- `sudo apt-get install -y python3 python3-pip`
- `sudo apt-get install -y pandoc`
- `sudo apt-get install -y texlive texlive-latex-extra texlive-fonts-recommended`
- `pip install pandas matplotlib numpy playwright`
- `playwright install chromium`
