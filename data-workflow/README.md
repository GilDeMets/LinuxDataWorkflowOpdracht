#README

## Data collectie

### Ophalen data

#### Clouds

> Hier haal ik de METAR data over de bewolking boven het vliegveld van Chievres in Henegouwen. Ik heb voor deze luchthaven gekozen omdat dit de dichtste is bij mij thuis. Ik heb hiervoor gekozen om te kijken bij welk soort bewolking ik effectief minder energie produceer. Deze data wordt om het half uur ge-update of vaker indien er een grote weersverandering is. Elk half uur is voldoende voor mijn case. Deze data wordt in plain text verkregen en deze verwerk ik dan mee tot de csv.
 
#### Price

> Hier haal ik de prijs van energie in Belgie op per minuut. Dit om een zo accuraat mogelijke prijsbepaling te hebben. Deze wordt opgehaald via een API-call en komt binnen als JSON. Deze wordt daarna omgezet tot csv.

#### Radiation

> Hier haal ik binnen hoeveel zonnestralen of radiation er doorkomen op de coordinaten van mijn huis. Dit wordt ook via een API-call binnen gehaald met curl. Met deze data en de gegevens van mijn installatie kan ik dan berekenen hoeveel mijn zonnepanelen zouden moeten opbrengen. 
 
#### Solar

> Hier haal ik de data van mijn eigen installatie binnen. Dit wordt jammer genoeg met een python-script gedaan omdat ik geen manier vond om de data gratis binnen te halen. De API-call kost geld en de data is enorm goed beveiligd waardoor ik ze niet gescrapet krijg. Ik probeerde headless windows, html scraping, ik probeer de zelfs lokaal via het ip van mijn omvormer aan de data te komen, maar helaas. Vandaar het python-script. Dit script download rechtstreeks van de pagina een csv-bestand dat ik daarna nog verwerk voor in mijn eigen CSV- bestand.

### Periode

> * Clouds: 19/11/2025 22:15 - xxxxxxxx elk half uur
> * Price: 19/11/2025 22:15 - xxxxxxxx elk uur lijnen -> 1 per minuut
> * Radiation: 19/11/2025 22:15 - xxxxxxxxx eenmaal per dag, 23:55
> * Solar: 19/11/2025 22:15 - xxxxxxxxx eenmaal per dag, 23:55

> Opmerking: Ik kan dit enkel lokaal op mijn laptop draaien, ik heb deze elk mogelijk moment laten aanstaan met de VM open, maar er zijn natuurlijk gaten als ik naar school en terug naar huis verplaats.

## install dependencies

- `pip install pandas`
- `pip install matplotlib`


