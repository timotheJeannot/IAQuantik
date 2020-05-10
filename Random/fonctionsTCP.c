#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include "fonctionTCP.h"


/* taille du buffer de reception */
#define TAIL_BUF 20

int socketServeur(ushort nPort){
    /* 
    * creation de la socket, protocole TCP 
    */
    int sockConx = socket(AF_INET, SOCK_STREAM, 0);
    if (sockConx < 0) {
        perror("(serveurTCP) erreur de socket");
        return -2;
    }

    /* 
    * initialisation de l'adresse de la socket 
    */

    struct sockaddr_in addServ;	/* adresse socket connex serveur */
    //struct sockaddr_in addClient;	/* adresse de la socket client connectee */
    
    addServ.sin_family = AF_INET;
    addServ.sin_port = htons(nPort); // conversion en format réseau (big endian)
    addServ.sin_addr.s_addr = INADDR_ANY; 
    // INADDR_ANY : 0.0.0.0 (IPv4) donc htonl inutile ici, car pas d'effet
    bzero(addServ.sin_zero, 8);

    int sizeAddr = sizeof(struct sockaddr_in);
	
	// le cas  qui suit est donné à la fin du sujet de tp
	int enable = 1;
	if (setsockopt(sockConx, SOL_SOCKET, SO_REUSEADDR, &enable,sizeof(int)) < 0)
	{
		perror("Erreur setsockopt");
		return -5; 
	}



    /* 
    * attribution de l'adresse a la socket
    */  
    int err = bind(sockConx, (struct sockaddr *)&addServ, sizeAddr);
    if (err < 0) {
    perror("(serveurTCP) erreur sur le bind");
    close(sockConx);
    return -3;
    }

    /* 
    * utilisation en socket de controle, puis attente de demandes de 
    * connexion.
    */
    err = listen(sockConx, 1);
    if (err < 0) {
    perror("(serveurTCP) erreur dans listen");
    close(sockConx);
    return -4;
    }
     
    return sockConx;
}

int socketClient(char* nomMachine , ushort nPort)
{
    int sock,                /* descripteur de la socket locale */
        //port,                /* variables de lecture */
        err;                 /* code d'erreur */
    //char* ipMachServ;        /* pour solution inet_aton */
    //char* nomMachServ;       /* pour solution getaddrinfo */
    struct sockaddr_in addSockServ;  
                            /* adresse de la socket connexion du serveur */
    //struct addrinfo hints;   /* parametre pour getaddrinfo */
    //struct addrinfo *result; /* les adresses obtenues par getaddrinfo */ 
    socklen_t sizeAdd;       /* taille d'une structure pour l'adresse de socket */

    
    /* 
    * creation d'une socket, domaine AF_INET, protocole TCP 
    */
    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        perror("(client) erreur sur la creation de socket");
        return -2;
    }

    /* 
    * initialisation de l'adresse de la socket - version inet_aton
    */

    addSockServ.sin_family = AF_INET;
    //err = inet_aton(ipMachServ, &addSockServ.sin_addr);
    err = inet_aton(nomMachine, &addSockServ.sin_addr);
    if (err == 0) { 
        perror("(client) erreur obtention IP serveur");
        close(sock);
        return -3;
    }

    addSockServ.sin_port = htons(nPort);
    bzero(addSockServ.sin_zero, 8);

    sizeAdd = sizeof(struct sockaddr_in);

    /* 
    *  initialisation de l'adresse de la socket - version getaddrinfo
    */
    /*
    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_family = AF_INET; // AF_INET / AF_INET6 
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = 0;
    hints.ai_protocol = 0;


    // récupération de la liste des adresses corespondante au serveur

    err = getaddrinfo(nomMachServ, argv[2], &hints, &result);
    if (err != 0) {
    perror("(client) erreur sur getaddrinfo");
    close(sock);
    return -3;
    }

    addSockServ = *(struct sockaddr_in*) result->ai_addr;
    sizeAdd = result->ai_addrlen;
    */
                    
    /* 
    * connexion au serveur 
    */
    err = connect(sock, (struct sockaddr *)&addSockServ, sizeAdd); 

    if (err < 0) {
        perror("(client) erreur a la connection de socket");
        close(sock);
        return -4;
    }
    return sock;
}

/*int main()
{
    return 0; 
}*/
