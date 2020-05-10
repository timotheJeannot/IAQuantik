#!/bin/sh

var=$(($2+1))
make
cd src/
export LD_LIBRARY_PATH=/usr/lib/swi-prolog/lib/amd64
#javac -cp /usr/lib/swi-prolog/lib/jpl.jar:../out/production/IAQuantik -d ../out/production/IAQuantik *.java
javac enums/*.java -d ../out/production/IAQuantik
javac -cp /usr/lib/swi-prolog/lib/jpl.jar:../out/production/IAQuantik -d ../out/production/IAQuantik *.java
cd ..
./joueur $1 $2 $3 & cd src
java -Djava.library.path=/usr/lib/swi-prolog/lib/amd64 -classpath $CLASSPATH:/usr/lib/swi-prolog/lib/jpl.jar:../out/production/IAQuantik Mediator localhost $var ../IA.pl
