#include "fonctionTCP.h"
#include "protocole.h"
#include "validation.h"
#include "random.h"
#include <time.h>

void viderBuffer()
{
    int c;
    do {
        c = getchar();
    } while (c != EOF && c != '\n');
}



int main (int argc, char ** argv)
{
    /* verification des arguments */
    if (argc != 3) {
        printf("usage : %s nom/IPServ port \n", argv[0]);
        return -1;
    }

    time_t t;
    /* Intializes random number generator */
    srand((unsigned) time(&t)); // à enlever si on finit par pas utiliser l'alé
                                // je commence par faire de l'aléa pour finir la partie communication
                                // de plus l'aléa peut être utilisé si l'ia ne répond pas à temps

    /************ Initialisation de la communication **********/

    char * serv = argv[1];
    int port = atoi(argv[2]);
    int port2 = port+1;
    struct sockaddr_in addClient;
    coupIA coupAdvIA;
    
    int socketConx = socketServeur(port2);
    if (socketConx < 0) {
        perror("Erreur création socket");
        return -1;
    }

    int sizeAddr = sizeof(struct sockaddr_in);
    int socketIA = accept(socketConx,
                       (struct sockaddr *)&addClient,
                       (socklen_t *)&sizeAddr);
    if (socketIA < 0) {
        perror("Erreur sur accept");
        return -1;
    }



    int socket = socketClient(serv,port); 
    if(socket < 0)
    {
        perror("(joueur) erreur sur la création de la socket");
        shutdown(socket, SHUT_RDWR); close(socket);
        return -1;
    }
    

    TPartieReq req = {PARTIE,"tjeannot",BLANC}; // pour le nom du joueur il faut relire le sujet , il faut faire ça avec le script

    int err = send(socket , &req,sizeof(TPartieReq),0);
    if (err <= 0) {
        perror("(joueur) erreur sur le send de la requête de partie");
        shutdown(socket, SHUT_RDWR); close(socket);
        return -5;
    }

    TPartieRep rep ;
    err = recv(socket,&rep,sizeof(TPartieRep),0);
    if (err <= 0) {
        perror("(joueur) erreur sur le recv de la requête réponse pour la partie");
        shutdown(socket, SHUT_RDWR); close(socket);
        return -5;
    }

    TCoul couleur = BLANC;
    if(rep.validCoulPion == KO)
    {
        couleur = NOIR;
    }

    int couleurIA = (couleur == BLANC) ? 0 : 1;
    couleurIA = htonl(couleurIA);

    err = send(socketIA, &couleurIA, sizeof(int), 0);

    if (err != sizeof(int)) {
        perror("(Erreur sur l'envoi de la couleur");
        shutdown(socket, SHUT_RDWR);
        close(socket);
        return -1;
        }

    /************* Fin initialisation de la communication *****************/

    /************* Début des parties ******************/

    for(int i = 0 ; i <2 ; i++)
    {
        int * plateau = iniPlateau();

        bool * pieces = iniPiecesDispo();

        bool * piecesAdv = iniPiecesDispo();

        int joueur = 1;
        if((couleur == NOIR && i ==0) || (couleur == BLANC && i==1))
        {
            joueur = 2;
        }

        bool cont = true;

        if(joueur == 2)
        {
            cont = false;
            TCoupRep repCoupAdv;
            err = recv(socket,&repCoupAdv,sizeof(TCoupRep),0);
            if (err <= 0) {
                perror("(joueur) erreur sur le recv de la requête réponse pour la validation du coup de l'adversaire");
                shutdown(socket, SHUT_RDWR); close(socket);
                return -5;
            }

            if(repCoupAdv.validCoup == VALID)
                {
                    TCoupReq coupAdve = {COUP,1,false,{BLANC,SPHERE},{UN,B},CONT};
                    err = recv(socket,&coupAdve,sizeof(TCoupReq),0);
                    if (err <= 0) {
                        perror("(joueur) erreur sur le recv de la requête réponse pour la validation du coup de l'adversaire");
                        shutdown(socket, SHUT_RDWR); close(socket);
                        return -5;
                    }

                    modifPlateauPieces(&plateau,&piecesAdv,coupAdve);
                    if(coupAdve.propCoup == CONT)
                    {
                        cont = true;

                        coupAdvIA.estBloque = htonl((int)coupAdve.estBloque);
                        coupAdvIA.typePion = htonl((int)coupAdve.pion.typePion);       
                        coupAdvIA.couleur = htonl((int)coupAdve.pion.coulPion);   
                        coupAdvIA.lignePion = htonl((int)coupAdve.posPion.l);      
                        coupAdvIA.colonnePion = htonl((int)coupAdve.posPion.c);    
                        coupAdvIA.propCoup = htonl((int)coupAdve.propCoup);

                    

                        err = send(socketIA, (const void *) &coupAdvIA, sizeof(coupIA), 0);
                        if (err != sizeof(coupIA)) {
                            perror("Erreur envoi coup adverse");
                            shutdown(socketIA, SHUT_RDWR);
                            close(socketIA);
                            return -1;
                        }
                    }
                }
        }

        while(cont)
        {

            //to do : Réception du coup crée par l'IA
            
            cont = false;
            TCoupReq coup = randomCoup(plateau,pieces,COUP,0,couleur);
        
            err = send(socket , &coup,sizeof(TCoupReq),0);
            if (err <= 0) {
                perror("(joueur) erreur sur le send de la requête de coup");
                shutdown(socket, SHUT_RDWR); close(socket);
                return -5;
            }
            TCoupRep repCoup;
            err = recv(socket,&repCoup,sizeof(TCoupRep),0);
            if (err <= 0) {
                perror("(joueur) erreur sur le recv de la requête réponse pour la validation du coup");
                shutdown(socket, SHUT_RDWR); close(socket);
                return -5;
            }

            if(repCoup.propCoup != CONT) {
                 int propCoupG = htonl(repCoup.propCoup);
                        err = send(socketIA, &propCoupG, sizeof(int), 0);
                        if (err != sizeof(int)) {
                            perror("Erreur envoi prop coup adverse");
                            shutdown(socketIA, SHUT_RDWR);
                            close(socketIA);
                            return -1;
                        }
            }

            if(repCoup.propCoup == GAGNE)
            {
                printf("Nous avons gagné la partie\n");
            }
            if(repCoup.propCoup == PERDU)
            {
                printf("Nous avons perdu la partie\n");
            }
            if(repCoup.propCoup == NUL)
            {
                printf("C'est un match nul\n");
            }

            if(repCoup.validCoup == VALID && repCoup.propCoup == CONT)
            {
                modifPlateauPieces(&plateau, &pieces , coup);
                TCoupRep repCoupAdv;
                err = recv(socket,&repCoupAdv,sizeof(TCoupRep),0);
                if (err <= 0) {
                    perror("(joueur) erreur sur le recv de la requête réponse pour la validation du coup de l'adversaire");
                    shutdown(socket, SHUT_RDWR); close(socket);
                    return -5;
                }
                if(repCoupAdv.validCoup == VALID && repCoupAdv.propCoup != GAGNE )
                {
                    TCoupReq coupAdv;
                    err = recv(socket,&coupAdv,sizeof(TCoupReq),0);
                    if (err <= 0) {
                        perror("(joueur) erreur sur le recv de la requête du coup de l'adversaire");
                        shutdown(socket, SHUT_RDWR); close(socket);
                        return -5;
                    }
                    if(repCoupAdv.propCoup != PERDU)
                    {
                        modifPlateauPieces(&plateau,&piecesAdv,coupAdv);
                    }

                    if(coupAdv.propCoup == CONT)
                    {
                        cont = true;


                        coupAdvIA.estBloque = htonl((int)coupAdv.estBloque);
                        coupAdvIA.typePion = htonl((int)coupAdv.pion.typePion);       
                        coupAdvIA.couleur = htonl((int)coupAdv.pion.coulPion);   
                        coupAdvIA.lignePion = htonl((int)coupAdv.posPion.l);      
                        coupAdvIA.colonnePion = htonl((int)coupAdv.posPion.c);    
                        coupAdvIA.propCoup = htonl((int)coupAdv.propCoup);

                    

                        err = send(socketIA, (const void *) &coupAdvIA, sizeof(coupIA), 0);
                        if (err != sizeof(coupIA)) {
                            perror("Erreur envoi coup adverse");
                            shutdown(socketIA, SHUT_RDWR);
                            close(socketIA);
                            return -1;
                        }
                    }
                    else {
                        int propCoupAdv = htonl((int)coupAdv.propCoup);
                        err = send(socketIA, &propCoupAdv, sizeof(int), 0);
                        if (err != sizeof(coupIA)) {
                            perror("Erreur envoi prop coup adverse");
                            shutdown(socketIA, SHUT_RDWR);
                            close(socketIA);
                            return -1;
                        }
                    }
                }
                else{
                    int propCoupG = htonl(GAGNE);
                        err = send(socketIA, &propCoupG, sizeof(int), 0);
                        if (err != sizeof(int)) {
                            perror("Erreur envoi prop coup adverse");
                            shutdown(socketIA, SHUT_RDWR);
                            close(socketIA);
                            return -1;
                        }
                }
                if(repCoupAdv.propCoup == GAGNE)
                {
                    printf("l'adversaire à gagné la partie\n");
                }
                if(repCoupAdv.propCoup == PERDU)
                {
                    printf("l'adversaire à perdu la partie\n");
                }
                if(repCoupAdv.propCoup == NUL)
                {
                    printf("C'est un match nul\n");
                }
            }
        }

        free(plateau);
        free(pieces);
        free(piecesAdv); // il faudrait aussi free dans les cas d'erreurs car on termine l'éxécution
    }
    /************* Fin des parties ******************/

    shutdown(socket,SHUT_RDWR);
    close(socket);

    return 0;
}