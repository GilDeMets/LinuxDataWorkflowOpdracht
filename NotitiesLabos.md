# Notities labo/les

## Labo 1

|Commando|Option|Output|
|--|-----|----|
|`curl`|`-o + <locatie>` | sla inhoud op in deze file|
| |`-i`|toon http headers|
| |`-L \| jq`|volg redirects, geeft gestructureerde JSON|
| |`-u + <username:wachtwoord>`|download met username en wachtwoord|
| |`-s`|silent mode, onderdrukt progress bar en foutmeldingen|
| 

## Redirects

|Commando|output|
|-|-|
|`<commando> > <file>` | redirect output commando naar file|
|`<commando> 2> <file>` | redirect fouten van commando naar file|
|`<commando> >> <file>` | redirect naar onderkant file|
|Combinatie van redirects mogelijk |vb. commando naar 1 file en errors naar 2e |
| `<commando> &> <file>` of `<commando> > <file> 2>&1` | zowel errors als output redirecten|
| `<commando> << _EOF_` | here document: Extern bestand in script steken -> dient om script wat properder te maken en verschillende regels na elkaar af te drukken.|
| `<command> \| <command>` | geeft eerste command door aan 2e command|

## Filtercommando's

Enkel output verandert, de file zelf verandert niet

|Commando|output|
|-|-|
| `\| tee` | schrijft weg naar bestand en naar op command line|
| `cat` | concatinate: alles van stinput afdrukken op stOut, vb samenvoegen van textfiles|
|`tac` | volgorde van lijnen omkeren |
|`shuf` | shuffle, inhoud wordt telkens in andere volgorde getoond |
|`head` | toont eerste 10 regels |
|`tail`| toont laatste 10 regels|
|`tail -f`| -f betekent follow, het systeem wacht tot als er iets komt
|`cut`| stukken uitknippen uit bestand | 
|`cut -d`|delimiter, gebruik volgend character ipv tab|
|`cut -f`| welke kolommen wil je tonen uit het bestand|
|`paste` | bestanden worden lijn per lijn toegevoegd aan elkaar|
|`join`| bestanden worden samengevoegd adhv gemeenschappelijke kolom, opties mogelijk voor keuze kolom, scheidingstekens... |
|`sort` | alfabetisch sorteren
|`sort -n` | sorteren op nummer|
|`sort -r` | omgekeerd sorteren|
|`uniq` | haalt alle dubbels er uit|
|`uniq -c` | telt hoeveel keer alles gebruikt is ook|
|`wc` | telt het aantal regels, woorden en lettertekens in bestand|
|`wc -l`|enkel regels|
|`nl`|bestand afdrukken met regelnummers voor, zonder lege regels|
|`fmt`| tekst herstructureren op spaties|
|`column -t`| input in tabelvorm|
|`column -s` | scheidingsteken toevoegen|
|`column -J` | vertalen naar JSON|
|`grep <wat> <waar>`| zoeken 'wat' in een bestand|
|`tr` | translate, char per char, voor characters te veranderen of te verwijderen|
|`sed 's/<zoek>/<vervang>/g'` |stream editor, zoek 'zoek' en vervang het door 'vervang', /g wil zeggen over heel de tekst|
|`sed '//d'`|verwijder |
|`awk '{<commando>}' <bestand>`| progammeertaal, bepaald commando invoeren in bestand|

## Script
### Inleiding

Je kan scripten schrijven met elke teksteditor. 

Verschllende manieren om een executable uit te voeren:
-   builtin
-   alias
-   executable in $PATH
-   absoluut pad naar exe

Permissies aanpassen van scriptfile om laatste mogelijkheid te kunnen uitvoeren.

### Shebang

`#!` + het absolute pad naar de interpreter van het script. Zo kan je bv python scripts uitvoeren in bash.

Extensie in de naam maakt niet uit, als je dit gebruikt. Bash kijkt naar het pad achter de shebang.

### Variabelen

Dubbele aanhalingstekens gebruiken. Zeker als je een variabele gebruikt. Anders wordt de variabele letterlijk afgedrukt.

`user=gil` variabele user = gil, geen spaties rond declareren van variabele. Als je variabele opvraagt altijd string + accollades gebruiken.

De scope van een variabele is binnen de shell. Een script schrijven is een subshell. Variabelen gedeclareerd buiten het script zijn dus niet zichtbaar.
Maar dit is te omzeilen door een omgevingsvariabele te maken. -> commando `export` gebruiken. Een variabele in een script bestaat niet meer na het uitvoeren van dat script. 

Binnen script kleine letters gebruiken. Omgevingsvariabelen met grote letters.

## Labo 2

### 2.1 Redirects en filters

1)  `apt list --installed`
2)  `apt list --installed > packages.txt`
3)  `apt list --installed &> packages.txt`
4)  `tail -n +2 packages.txt | head`
5)  `wc -l packages.txt`
6)  `cat packages.txt | awk '{print $3}' | sort | uniq -c`
7)  `grep python packages.txt | wc -l`
8)  


