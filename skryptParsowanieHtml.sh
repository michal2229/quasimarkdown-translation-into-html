#!/bin/bash

# dzialanie programu:
# 1. interpretacja parametrow i sprawdzenie ich kompletnosci
# 2. sprawdzenie czy pliki zrodlowe istnieja
# 3. przetwarzanie plikow za pomoca wyrazen regularnych
# 4. dolaczenie szablonu html

tytulHtml="strona z txt"
kolorTla="#a0a0c0"
kolorCzcionki="#112211"

blad=false
wykonajListaPlikow=()

argumentPomoc1="-h"
argumentPomoc2="--help"
pomoc=false
tekstPomocy="Aby costam to costam.
Aby cos innego to cos innego itd."

argumentZapisDoPliku="-f"
zapisDoPliku=false;
nazwaPliku=""

argumentVerbose="-v"
verbose=false

tekstBlednyArgument="Bledny argument. Obslugiwane argumenty to: -h, --help, -f nazwapliku.html, -v. 
Uzycie: skryptParsowanieHtml plik1 [plik2...plikn] [-h | --help] [-v] [-f nazwaPlikuDocelowego]"

tekstBrakPliku="Nie mozna znalezc pliku:"

j=0 # numer odczytanego pliku do przetworzenia (0, 1, ...)
k=1 # zmienna pomocnicza numerujaca powtarzajace sie nazwy

# interpretacja parametrow uzytkownika
for ((i=1;i<=$#;i++)); 
do
 	if [ ${!i:0:1} = "-" ] 
	then
	    if  [ ${!i} = $argumentPomoc1 ] || [ ${!i} = $argumentPomoc2 ] 
	    then  echo "$tekstPomocy";
	    elif [ ${!i} = $argumentZapisDoPliku ];
	    then zapisDoPliku=true; ((i++)); 
	    	if [ $i -gt $# ]
	    	then
				echo "$tekstBlednyArgument"
				blad=true
			else 
		    	if [ ${!i:0:1} != "-" ]
		    	then 
		    		nazwaPliku=${!i}
		    	else 
		    		echo "$tekstBlednyArgument"
					blad=true
		    	fi	
			fi
	    elif [ ${!i} = $argumentVerbose ];
	    then verbose=true;  
	    else 
	    	echo "$tekstBlednyArgument"
	    	blad=true
	    fi
	else 
		wykonajListaPlikow[j]=${!i}
		((j++))
	fi
done;


# program glowny
if [ $blad = false ]
then
	if [ $verbose = true ] 
	then
		echo "Rozpoczynanie przetwarzania plikow."
	fi
	for i in ${wykonajListaPlikow[@]}; 
	do
		if [ $verbose = true ] 
		then
			echo "Przetwarzanie pliku $i."
		fi
		if [ -e $i ]
		then
			if [ $verbose = true ] 
			then
				echo "Plik $i istnieje."
			fi
			text=$(cat $i) #wczytanie pliku do zmiennej

			htmlPrzedTekstem="<html><head><title>$tytulHtml</title></head><body bgcolor=$kolorTla><p align='center'><font color=$kolorCzcionki>"
			htmlPoTekscie="</p></font></body></html>"

			if [ $verbose = true ] 
			then
				echo "Parsowanie pliku $i."
			fi

			# podstawianie ciagow znakow innymi ciagami
			text=$(printf "$text" | sed -e 's/ \*/ <b>/g'		-e 's/\* /<\/b> /g' 			\
									-e 's/ \// <i>/g'			-e 's/\/ /<\/i> /g' 			\
									-e 's/\[/<IMG SRC\=\"/g'  	-e 's/\]/\" height="240">/g' 	\
									-e 's/ #/ <A HREF\=\"/g'  	-e 's/# /\"> link <\/A> /g'		\
									-e 's/\t/<BR>/g' 											\
									-e 's/$/<BR>/g' ) 
			if [ $zapisDoPliku = true ] 
			then
				# pakowanie tekstu do html
				nazwaPlikuTemp=$nazwaPliku
				if [ ${#wykonajListaPlikow[@]} -gt 1 ] 
				then
					
					nazwaPlikuTemp="$k$nazwaPlikuTemp"
					((k++))

					if [ $verbose = true ] 
					then
						echo "Zmiana nazwy pliku docelowego $nazwaPliku na $nazwaPlikuTemp w celu unikniecia powtarzania nazw w folderze."
					fi
				fi
				echo "$htmlPrzedTekstem
$text
$htmlPoTekscie" > $nazwaPlikuTemp
				if [ $verbose = true ] 
				then
					echo "Zapis przetworzonego pliku $nazwaPlikuTemp."
				fi
			else	
				# wyswietlanie tekstu w terminalu
				echo "$htmlPrzedTekstem
$text
$htmlPoTekscie"
			fi
		else 
			echo "$tekstBrakPliku $i"
		fi	
	done;
fi
if [ $verbose = true ] 
then
	echo "Zakonczono."
fi
exit 0