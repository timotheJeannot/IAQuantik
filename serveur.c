#include "fonctionTCP.h"
#include "protocole.h"
#include "validation.h"
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/syscall.h>
#include <unistd.h>

void closeSocks (int sockConx, int sockTrans1,int sockTrans2)
{
    shutdown(sockTrans1, SHUT_RDWR);
    close(sockTrans1);
    shutdown(sockTrans2, SHUT_RDWR);
    close(sockTrans2);
    shutdown(sockConx, SHUT_RDWR);
    close(sockConx);

}

void jouerPartie(int sockTransJ1, int sockTransJ2 , int sockConx)
{
    initialiserPartie();

    bool cont = true;

    while(cont)
    {
        cont = false;
        TCoupReq coupJ1;
        int err = recv(sockTransJ1, &coupJ1, sizeof(TCoupReq), 0);
        if (err <= 0) {
            perror("(serveur) erreur dans la reception de la requête de coup de j1");
            closeSocks(sockConx,sockTransJ1,sockTransJ2);                   
        }

        TPropCoup propCJ1;
        bool valide = validationCoup(1,coupJ1,&propCJ1);    
        TCoupRep repCJ1 ;
        repCJ1.err = ERR_OK; // ici revoir le sujet il faut vérifier un truc
        if(valide)
        {
            repCJ1.validCoup = VALID;
        }
        else
        {
            repCJ1.validCoup = TRICHE; // ici il y a timeout comme valeur possible
        }
        repCJ1.propCoup = propCJ1;

        err = send(sockTransJ1, &repCJ1 , sizeof(TCoupRep),0);
        if (err <= 0) {
            perror("(serveur) erreur dans l'envoie de la validation du coup à j1");
            closeSocks(sockConx,sockTransJ1,sockTransJ2);                   
        }

        err = send(sockTransJ2, &repCJ1 , sizeof(TCoupRep),0);
        if (err <= 0) {
            perror("(serveur) erreur dans l'envoie de la validation du coup de j1 à j2");
            closeSocks(sockConx,sockTransJ1,sockTransJ2);                   
        }

        if(valide)
        {
            if(coupJ1.propCoup != GAGNE)
            {
                err = send(sockTransJ2, &coupJ1 , sizeof(TCoupReq),0);
                if (err <= 0) {
                    perror("(serveur) erreur dans l'envoie du coup de j1 à j2");
                    closeSocks(sockConx,sockTransJ1,sockTransJ2);                   
                }
            }

            if( coupJ1.propCoup == CONT)
            {
                TCoupReq coupJ2;
                err = recv(sockTransJ2, &coupJ2, sizeof(TCoupReq), 0);
                if (err <= 0) {
                    perror("(serveur) erreur dans la reception de la requête de coup de j2");
                    closeSocks(sockConx,sockTransJ1,sockTransJ2);                   
                }

                TPropCoup propCJ2;
                bool valide2 = validationCoup(2,coupJ2,&propCJ2);

                TCoupRep repCJ2 ;
                repCJ2.err = ERR_OK; // ici revoir le sujet il faut vérifier un truc
                if(valide2)
                {
                    repCJ2.validCoup = VALID;
                }
                else
                {
                    repCJ2.validCoup = TRICHE; // ici il y a timeout comme valeur possible
                }
                repCJ2.propCoup = propCJ2;

                err = send(sockTransJ2, &repCJ2 , sizeof(TCoupRep),0);
                if (err <= 0) {
                    perror("(serveur) erreur dans l'envoie de la validation du coup à j2");
                    closeSocks(sockConx,sockTransJ1,sockTransJ2);                   
                }

                err = send(sockTransJ1, &repCJ2 , sizeof(TCoupRep),0);
                if (err <= 0) {
                    perror("(serveur) erreur dans l'envoie de la validation du coup de j1 à j2");
                    closeSocks(sockConx,sockTransJ1,sockTransJ2);                   
                }

                if(valide2)
                {
                    if(propCJ2 != GAGNE)
                    {
                        err = send(sockTransJ1, &coupJ2 , sizeof(TCoupReq),0);
                        if (err <= 0) {
                            perror("(serveur) erreur dans l'envoie du coup de j2 à j1");
                            closeSocks(sockConx,sockTransJ1,sockTransJ2);                   
                        }
                    }

                    if(propCJ2 == CONT)
                    {
                        cont = true;
                    }
                }
            }
        }
    
    }
}

int main (int argc, char ** argv)
{
    if (argc != 2) {
        printf ("usage : %s port\n", argv[0]);
        return -1;
    }

    /************ Initialisation de la communication **********/

    int port  = atoi(argv[1]);
    int sockConx = socketServeur(port);
    if(sockConx < 0)
    {
        perror("erreur dans la création de la socket de connexion");
        return -2 ; // se renseigner sur les codes d'erreurs à renvoyer
    }

    int sizeAddr = sizeof(struct sockaddr_in);


    struct sockaddr_in addJ1;

    int sockTransJ1 = accept(sockConx, 
                (struct sockaddr *)&addJ1, 
                (socklen_t *)&sizeAddr);
    
    if (sockTransJ1 < 0) {
        perror("(serveurTCP) erreur sur accept");
        shutdown(sockTransJ1, SHUT_RDWR);
        close(sockTransJ1);
        shutdown(sockConx, SHUT_RDWR);
        close(sockConx);
        return -5;
    }

    struct sockaddr_in addJ2;

    int sockTransJ2 = accept(sockConx, 
                (struct sockaddr *)&addJ2, 
                (socklen_t *)&sizeAddr);
    
    if (sockTransJ2 < 0) {
        perror("(serveurTCP) erreur sur accept");
        closeSocks(sockConx,sockTransJ1,sockTransJ2);
        return -5;
    }

    TPartieReq reqJ1 ;
    int err = recv(sockTransJ1, &reqJ1, sizeof(TPartieReq), 0);
    if (err <= 0) {
        perror("(serveur) erreur dans la reception de la première requête de partie");
        closeSocks(sockConx,sockTransJ1,sockTransJ2);                   
    }

    TPartieReq reqJ2 ;
    err = recv(sockTransJ2, &reqJ2, sizeof(TPartieReq), 0);
    if (err <= 0) {
        perror("(serveur) erreur dans la reception de la seconde requête de partie");
        closeSocks(sockConx,sockTransJ1,sockTransJ2);                   
    }

    TPartieRep repJ1;
    repJ1.err = ERR_OK;
    strcpy(repJ1.nomAdvers,reqJ2.nomJoueur);
    repJ1.validCoulPion= OK;

    TPartieRep repJ2;
    repJ2.err = ERR_OK;
    strcpy(repJ2.nomAdvers,reqJ1.nomJoueur);
    if(reqJ1.coulPion == reqJ2.coulPion)
    {
         repJ2.validCoulPion = KO;
    }
    else
    {
         repJ2.validCoulPion = OK;
    }

    err = send(sockTransJ1, &repJ1 , sizeof(TPartieRep),0);
    if (err <= 0) {
        perror("(serveur) erreur dans l'envoie au premier joueur sur la réponse de la demande de partie");
        closeSocks(sockConx,sockTransJ1,sockTransJ2);                   
    }

    err = send(sockTransJ2, &repJ2 , sizeof(TPartieRep),0);
    if (err <= 0) {
        perror("(serveur) erreur dans l'envoie au second joueur sur la réponse de la demande de partie");
        closeSocks(sockConx,sockTransJ1,sockTransJ2);                   
    }
    
    /************* Fin initialisation de la communication *****************/

    /************* Début de la première partie ******************/
    jouerPartie(sockTransJ1,sockTransJ2,sockConx);
    /************* Fin de la première partie ******************/

    /************* Début de la seconde partie ******************/
    jouerPartie(sockTransJ2,sockTransJ1,sockConx);
    /************* Fin de la seconde partie ******************/
    
    return 0;
}