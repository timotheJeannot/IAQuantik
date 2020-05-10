#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <sys/types.h>

/*
    Le but de ce programme est de se faire rencontrer N fois deux joueurs.c
    avec l'arbitre donnée par les enseignants. Le programme doit détecter si
    il y a eu un soucis lors d'une rencontre (par exemple mauvais propriéte du coup)
    et écrire le déroulement du match erroné dans un fichier.
    Il doit aussi noter les scores des N matchs dans un autre fichier.

    Nous avons choisi de faire ce programme dans le cadre des tests qui nous
    ont été demandé dans la partie IA du projet.
    L'utilité est de pouvoir l'utiliser avec le random afin de pouver tester
    dans pas mal de configurations l'ia codé en prolog.
    De plus si le temps le permet et que des nouvelles versions de l'ia sont implémenter.
    Ce programme peut vérifier que ces nouvelles version sont effectivement meilleurs
    en faisant des rencontres entre le random et les anciennes versions implémentées

    arguments du programme:
        nombresDeMatch nomExecutableJoueur1 nomExecutableJoueur2

    fichiers généré :
        erreurMatchTrouvé(X) : X ième match erroné avec détails

        score : scores des N matchs
*/


void handler(int signumber)
{
    printf("wtf ? \n");
    return;
}

int main(int argc, char **argv )
{
    if(argc != 4)
    {
        printf("usage : %s nombresDeMatch nomExecutableJoueur1 nomExecutableJoueur2 \n",argv[0]);
        return -1;
    }
    
    char *newenviron[] = { NULL };

    int parent_pid = getpid();

    signal(SIGUSR1,handler);

    signal(SIGUSR2,handler);

    int pid = fork();

    if(pid == -1)
    {
        perror("erreur dans le premier fork");
        return -2;
    }

    int pidFils1;

    if(pid == 1) // on est dans le père
    {
        int pid2 = fork();
        if( pid2 == -1)
        {
            perror("erreur dans le deuxieme fork");
            return -2;
        }

        int pidFils2;

        if(pid == 1) // on est dans le père à nouveau
        {
            printf("on est dans le père \n");

            pause();
            //signal(SIGUSR1,handler);
            pause();
            //signal(SIGUSR2,handler);

            printf("test\n");

            kill(pidFils1,SIGUSR1);
            kill(pidFils2,SIGUSR1);

            printf("fin du père\n");
            /*char *newargv[] = {"./serveur","1099", NULL};

            execve("./serveur",newargv,newenviron);
            
            perror("execve");
            return -3;*/
            
        }

        if(pid2 == 0) // on est dans le deuxième fils
        {
            printf("on est dans le deuxième fils\n");
            //system("./joueur  127.0.0.1 1099");
            //execl(".","./joueur ","127.0.0.1","1099",NULL);
            
            pidFils2 = getpid();

            kill(parent_pid,SIGUSR1);

            pause();
            //signal(SIGUSR2,handler);

            printf("fin du deuxième fils \n");
            /*char *newargv[] = {"./joueur","127.0.0.1", "1099" , NULL };

            execve("./joueur",newargv,newenviron);

            perror("execve");
            return -3;*/

            
        }
    }
    if(pid == 0) // on est dans le premier fils
    {
        printf("on est dans le premier fils \n");

        pidFils1 = getpid();

        kill(parent_pid,SIGUSR1);
        
        sleep(3);
        pause();
        //signal(SIGUSR1,handler);

        printf("fin du premier fils \n");
        /*char *newargv[] = {"./joueur","127.0.0.1", "1099" , NULL};

        execve("./joueur",newargv,newenviron);
        
        perror("execve");
        return -3;*/
        
    }

    

    return 0;
}