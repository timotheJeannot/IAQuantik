
all : serveur joueur 

serveur : serveur.c fonctionsTCP.o
	gcc -Wall serveur.c fonctionsTCP.o quantik-fPIC.o -o serveur

joueur: joueur.c fonctionsTCP.o random.o
	gcc -Wall joueur.c fonctionsTCP.o random.o quantik-fPIC.o -o joueur

fonctionsTCP.o : fonctionsTCP.c
	gcc -c fonctionsTCP.c

random.o : random.c
	gcc -c random.c


clean:
	rm *~ ; rm -i \#* ; rm *.o; \
        rm serveur ; rm joueur
