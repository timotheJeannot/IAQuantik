#include "random.h"


//tout ce qui est dans ce fichier sera à faire surtout dans la partie IA (java/prolog)
// je laisse ça là pour le moment pour faire du random et faire la partie communication
// on pourra l'utiliser plus tard si l'ia ne renvoie pas un coup en temps voulue

// je fais ça car il me semble plus judicieux de finir la partie communication
// la partie IA peut toujours être perfectionné et j'ai peur qu'on passe trop 
// de temps dessus par rapport à la communication

/*Plateau:
    -dimension : les cases du plateau ( 1A = 0 ; 1D = 3 ; 2A = 4 ; ...)

    -valeur ciblé : 
        -O = pas de pion
        -1 = 1er pavé blanc
        -2 = 2nde pavé blanc
        -3 = 1er cylindre blanc
        -4 = 2nde cylindre blanc
        -5 = 1ere sphère blanc 
        -6 = 2ere sphère blanc
        -7 = 1ere tétraèdres blanc
        -8 = 2nde tétraèdres blanc
        -9 = 1er pavé noir
        -...
        - 16 = 2nde tétraèdres noir
*/


/************* gestion des la construction des coups ***************/

TCoupReq buildCoup (TLg l, TCol c, int p, int bloque, int propCoup, TIdReq idRequest, int numPartie, TCoul couleur)
{

    TPion pion;
    pion.coulPion = couleur;

    TCase posPion;

 
    pion.typePion = p;

    
    posPion.l = l;
    posPion.c = c;
    TCoupReq ret ;
    ret.idRequest = idRequest;
    ret.numPartie = numPartie;
    ret.estBloque = bloque;
    ret.pion = pion;
    ret.posPion = posPion;
    ret.propCoup = propCoup;
    
    return ret;
}

coupIA buildCoupIA (int bloque, int p, TLg l, TCol c, int propCoup)
{

    coupIA coup;
    coup.propCoup = propCoup;
    coup.estBloque = bloque;    
    coup.typePion = p;         
    coup.lignePion = l;      
    coup.colonnePion = c;  

    return coup;
}

/************ gestions coups random **************/



void addTab (struct tab * tab, int value)
{
    if(tab->size == tab->capacity)
    {
        tab->capacity = tab->capacity*2;
        int * newTab = malloc(tab->capacity*sizeof(int));
        memcpy(newTab,tab->tab,tab->size*sizeof(int));
        free(tab->tab);
        tab->tab = newTab;
    }
    tab->tab[tab->size] = value;
    tab->size = tab->size +1;
}


int * iniPlateau ()
{
    int * plateau = malloc(16*sizeof(int));
    for(int i =0 ; i< 16 ; i++)
    {
        plateau[i] = 0;
    }
    return plateau;

}

// la fonction suivante va créer un tableau des positons possible pour la pièce ( voir la description du plateau)
// ce que je fais dans la focntion est sûrement pas optimal mais cela ne doit pas être important
// car le plateau est relativement petit
struct tab tablePositionsPiece( int * plateau , int piece , TCoul couleurAdv)
{
    int pieceAdv ;
    if(couleurAdv == NOIR)
    {
        pieceAdv = piece+8;
    }
    else
    {
        pieceAdv = piece -8;
    }
    
    if(piece%2 ==0)
    {
        pieceAdv -= 1; /* il faut faire gaffe car il y a deux codes pour chaquetypes de chaque pièces
                         je me met sur le premier code et j'aurais juste à faire +1
                         plus tard pour vérifier le prochain code */
    }

    // on va lister les cases non disponibles par les règles
    struct tab casesBloque;
    casesBloque.tab = malloc(sizeof(int));
    casesBloque.size = 0;
    casesBloque.capacity = 1;

    for(int i =0; i < 16; i ++)
    {
        if(plateau[i] == pieceAdv || plateau[i] == pieceAdv +1)
        {
            int colonne = i %4;
            int ligne = (i-colonne)/4;

            // cas de la ligne
            for(int j = 0; j<4 ; j++)
            {
                if(j != colonne) // pas besoin d'ajouter que la piece bloque sa case
                {
                    addTab(&casesBloque,ligne*4+j);
                }
            }

            //cas de la colonne
            for(int j = 0; j<4 ; j++)
            {
                if( j != ligne) // pas besoin d'ajouter que la piece bloque sa case
                {
                    addTab(&casesBloque,j*4+colonne);
                }
            }

            //cas du carrée

            //cas de la case en haut à gauche du carré
            if(i == 0||i == 2||i == 8||i == 10)
            {
                addTab(&casesBloque,i+1);
                addTab(&casesBloque,i+4);
                addTab(&casesBloque,i+5);                
            }

            //cas de la case en haut à droite du carré
            if(i == 1||i == 3||i == 9||i == 11)
            {
                addTab(&casesBloque,i-1);
                addTab(&casesBloque,i+4);
                addTab(&casesBloque,i+3);                
            }

            //cas de la case en bas à gauche du carré
            if(i == 4||i == 6||i == 12||i == 14)
            {
                addTab(&casesBloque,i-4);
                addTab(&casesBloque,i+1);
                addTab(&casesBloque,i-3);                
            }

            //cas de la case en bas à droite du carré
            if(i == 5||i == 7||i == 13||i == 15)
            {
                addTab(&casesBloque,i-1);
                addTab(&casesBloque,i-4);
                addTab(&casesBloque,i-5);                
            }
            
        }
    }
    
    // on va pouvoir regarder maintenant les cases disponibles
    struct tab ret;
    ret.tab = malloc(sizeof(int));
    ret.size = 0;
    ret.capacity = 1;

    for(int i = 0; i< 16 ; i ++)
    {
        if( plateau[i] == 0) // si il n'y a pas de pièce sur la case
        {
            bool test = true;
            int compteur = 0;
            while(compteur<casesBloque.size && test)
            {
                if(i == casesBloque.tab[compteur])
                {
                    test = false; 
                }
                compteur++;
            }
            if(test)
            {
                addTab(&ret,i);
            }
        }
    }
    free(casesBloque.tab);
    return ret;
}

// on va renvoyer un tableau à deux éléments qui contiennt la position (ret[0]) et la piece joué 
int * jouerRandom (int * plateau , bool * pieces,TCoul coulAdv)
{
    int PlusCouleur = 0;
    if(coulAdv == BLANC)
    {
        PlusCouleur = 8;
    }
    
    bool test = true;
    int compteur = 0;

    int * ret = malloc(2*sizeof(int));
    while(compteur < 8 && test)
    {
        if(pieces[compteur]) // piece dispo
        {
            struct tab positions = tablePositionsPiece(plateau,compteur+1+PlusCouleur,coulAdv);
            
            if(positions.size > 0)
            {
                int Rand = rand() % (positions.size);
                ret[0] = positions.tab[Rand];
                ret[1] = compteur;
                test = false;
            }
            free(positions.tab);
        }
        compteur++;
    }
    
    if(test) // on est bloqués
    {
        ret[0] = -1;
        ret[1] = -1;
    }
    return ret;
}



// true pièce présent et false sinon , les pions sont représentés dans la dimension
// dans le même ordre que dans la valeur cible du plateau sauf qu'ils commencent à 0
bool * iniPiecesDispo ()
{
    bool * tab = malloc(8*sizeof(bool));
    for(int i =0 ; i<8 ; i++)
    {
        tab[i] = true;
    }

    return tab;
}

// je suppose qu'il est impossible que le tableau ne contiennent que des false
// si il n'y a plus de pièce dispo la partie prend fin et la fonction 
//ne devrait pas être appellé
//si tab ne contient que des false on a une boucle infini
// donc si ma supposition est fausse il faut faire une vérif
int randomPieceDispo (bool * tab)
{
    int Rand = rand() % 8;
    int ret = 0;
    while(Rand != -1)
    {
        if(tab[ret])
        {
            Rand --;
        }
        ret++;
        ret = ret%8;
    }
    ret --;
    if(ret == -1)
    {
        ret = 7;
    }
    return ret;
}

TTypePion intToTTypePion (int piece)
{
    if(piece == 0 || piece == 1)
    {
        return PAVE;
    }
    if(piece == 2 || piece == 3)
    {
        return CYLINDRE;
    }
    if(piece == 4 || piece == 5)
    {
        return SPHERE;
    }
    if(piece == 6 || piece == 7)
    {
        return TETRAEDRE;
    }
    return PAVE ; 
}



TCase intToTCase (int Case)
{
    int colonne = Case%4;
    int ligne = (Case-colonne)/4;

    TCol col = A; // c'est pour enlever le warning
    switch (colonne)
    {
        case 0:
            col = A;
        break;

        case 1:
            col = B;
        break;

        case 2:
            col = C;
        break;

        case 3:
            col = D;
        break;

    }
    
    TLg lg  = UN; // c'est pour enlever le warning
    switch (ligne)
    {
        case 0:
            lg = UN;
        break;

        case 1:
            lg = DEUX;
        break;

        case 2:
            lg = TROIS;
        break;

        case 3:
            lg = QUATRE;
        break;
    }
    TCase ret = {lg,col};
    return ret;
}


/********************* partie calcule de la propriété du coup ******************/


bool estPave(int * plateau , int Case)
{
    if(plateau[Case] == 1 || plateau[Case] == 2 || plateau[Case] == 9 || plateau[Case] == 10)
    {
        return true;
    }
    return false;
}

bool estCylindre(int * plateau , int Case)
{
    if(plateau[Case] == 3 || plateau[Case] == 4 || plateau[Case] ==11 || plateau[Case] == 12)
    {
        return true;
    }
    return false;
}

bool estSphere(int * plateau , int Case)
{
    if(plateau[Case] == 5 || plateau[Case] == 6 || plateau[Case] == 13 || plateau[Case] == 14)
    {
        return true;
    }
    return false;
}

bool estTetraedre(int * plateau , int Case)
{
    if(plateau[Case] == 7 || plateau[Case] == 8 || plateau[Case] == 15 || plateau[Case] == 16)
    {
        return true;
    }
    return false;
}

// regarde si il y a les quatres formes sur une ligne du plateau
bool gagneLigne(int *plateau)
{
    // avec un codage du plateau mieu fait , il doit y avoir moyen
    // de sommer les valeurs de la ligne du plateau et de regarder le nombre
    // obtenu pour savoir si oui ou non on a les quatres formes différentes
    // donc si on a le temps ceci est à améliorer
    // de tout façon il serait pas mal de changer le plateau car il y a une
    //duplication de l'info il n'y a pas besoin de savoir si c'est le 1er
    // ou le 2ieme pion du même type. Cette information devrait être juste présente
    // dans tableau de bool pieces disponibles

    bool testWin = true;
    int compteurL = 0;

    while(compteurL < 4 && testWin)
    {
        bool testP = true;
        int compteurP = 0;
        while(compteurP <4 && testP)
        {
            int Case = compteurL*4+compteurP;
            if(estPave(plateau,Case))
            {
                testP = false; // ca ne sert à rien de chercher un autre pavé
                bool testC = true;
                int compteurC = 0 ;
                while(compteurC < 4 && testC)
                {
                    Case = compteurL*4+compteurC;
                    if(estCylindre(plateau,Case))
                    {
                        testC = false;
                        bool testS = true;
                        int compteurS = 0;
                        while(compteurS < 4 && testS)
                        {
                            Case = compteurL*4+compteurS;
                            if(estSphere(plateau,Case))
                            {
                                testS = false;
                                bool testT = true;
                                int compteurT = 0;
                                while(compteurT<4 && testT)
                                {
                                    Case = compteurL*4+compteurT;
                                    if(estTetraedre(plateau,Case))
                                    {
                                        testT = false;
                                        testWin = false;
                                    }
                                    compteurT ++;
                                }
                            }
                            compteurS ++;
                        }
                    }
                    compteurC ++;
                }
            }
            compteurP++;
        }
        compteurL++;
    }
    return !testWin;
}

bool gagneColonne (int *plateau)
{
    bool testWin = true;
    int compteurCo = 0;

    while(compteurCo < 4 && testWin)
    {
        bool testP = true;
        int compteurP = 0;
        while(compteurP <4 && testP)
        {
            int Case = compteurCo+compteurP*4;
            if(estPave(plateau,Case))
            {
                testP = false; // ca ne sert à rien de chercher un autre pavé
                bool testC = true;
                int compteurC = 0 ;
                while(compteurC < 4 && testC)
                {
                    Case = compteurCo+compteurC*4;
                    if(estCylindre(plateau,Case))
                    {
                        testC = false;
                        bool testS = true;
                        int compteurS = 0;
                        while(compteurS < 4 && testS)
                        {
                            Case = compteurCo+compteurS*4;
                            if(estSphere(plateau,Case))
                            {
                                testS = false;
                                bool testT = true;
                                int compteurT = 0;
                                while(compteurT<4 && testT)
                                {
                                    Case = compteurCo+compteurT*4;
                                    if(estTetraedre(plateau,Case))
                                    {
                                        testT = false;
                                        testWin = false;
                                    }
                                    compteurT ++;
                                }
                            }
                            compteurS ++;
                        }
                        
                    }
                    compteurC ++;
                }
            }
            compteurP++;
        }
        compteurCo++;
    }
    return !testWin;  
}

bool gagneCarree (int * plateau)
{
    bool testWin = true;
    int compteurCa = 0;

    while(compteurCa < 4 && testWin)
    {
        bool testP = true;
        int compteurP = 0;
        int caseCHG = 0; // casse du carrée en haut à gauche
        switch(compteurCa){
            case 0:
                caseCHG = 0 ; // pas besoin de faire ce cas il est juste en haut
            break;

            case 1:
                caseCHG = 2;
            break;

            case 3:
                caseCHG = 8;
            break;

            case 4:
                caseCHG = 10;
            break;
        }
        while(compteurP <4 && testP)
        {
            int Case = 0;
            if(compteurP ==0 || compteurP==1)
            {
                Case = caseCHG+compteurP;
            }
            else
            {
                Case = caseCHG+compteurP+2;
            }
            
            if(estPave(plateau,Case))
            {
                testP = false; // ca ne sert à rien de chercher un autre pavé
                bool testC = true;
                int compteurC = 0 ;
                while(compteurC < 4 && testC)
                {
                    Case = 0;
                    if(compteurC ==0 || compteurC==1)
                    {
                        Case = caseCHG+compteurC;
                    }
                    else
                    {
                        Case = caseCHG+compteurC+2;
                    }
                    if(estCylindre(plateau,Case))
                    {
                        testC = false;
                        bool testS = true;
                        int compteurS = 0;
                        while(compteurS < 4 && testS)
                        {
                            Case = 0;
                            if(compteurS ==0 || compteurS==1)
                            {
                                Case = caseCHG+compteurS;
                            }
                            else
                            {
                                Case = caseCHG+compteurS+2;
                            }
                            if(estSphere(plateau,Case))
                            {

                                testS = false;
                                bool testT = true;
                                int compteurT = 0;
                                while(compteurT<4 && testT)
                                {
                                    Case = 0;
                                    if(compteurT ==0 || compteurT==1)
                                    {
                                        Case = caseCHG+compteurT;
                                    }
                                    else
                                    {
                                        Case = caseCHG+compteurT+2;
                                    }
                                    if(estTetraedre(plateau,Case))
                                    {
                                        testT = false;
                                        testWin = false;
                                    }
                                    compteurT ++;
                                }
                            }
                            compteurS ++;
                        }
                        
                    }
                    compteurC ++;
                }
            }
            compteurP++;
        }
        compteurCa++;
    }
    return !testWin;
}


bool gagne (int *plateau)
{
    return gagneLigne(plateau)||gagneColonne(plateau)||gagneCarree(plateau);
}

/********************* fin partie calcule de la propriété du coup ******************/



TCoupReq randomCoup (int * plateau , bool * pieces ,TIdReq idRequest, int numPartie, TCoul couleur)
{
 
    TCoul coulAdv ;
    if(couleur == BLANC)
    {
        coulAdv = NOIR;
    }
    else
    {
        coulAdv = BLANC;
    }

    int * coup = jouerRandom(plateau,pieces,coulAdv);

    bool bloque = false;

    TPion pion;
    pion.coulPion = couleur;

    TCase posPion;

    if(coup[0] == -1)
    {
        bloque = true;

        pion.typePion = PAVE;

        posPion.l = UN;
        posPion.c = A;
    }
    else
    {
        pion.typePion = intToTTypePion(coup[1]);

        posPion = intToTCase(coup[0]);
    }
    
    TCoupReq ret ;
    ret.idRequest = idRequest;
    ret.numPartie = numPartie;
    ret.estBloque = bloque;
    ret.pion = pion;
    ret.posPion = posPion;

    
    TPropCoup prop;

    if(bloque)
    {
        prop = PERDU;
    }
    else
    {
        plateau[coup[0]]=coup[1]+1;
        bool testComplet = true;
        int compteur =0;
        while(compteur <16 && testComplet)
        {
            if(plateau[compteur] == 0)
            {
                testComplet = false;
            }
            compteur++;
        }
        if(testComplet)
        {
            prop = NUL;

        }
        else
        {
            if(gagne(plateau))
            {
                prop = GAGNE;
            }
            else
            {
                prop = CONT;
            }
            
        }
    }
    ret.propCoup = prop;
    
    free(coup);

    return ret;
}

int TCaseToInt(TCase Case)
{
    int ligne =0;
    switch (Case.l)
    {
        case UN:
            ligne = 0;
        break;

        case DEUX:
            ligne = 1;
        break;

        case TROIS:
            ligne = 2;
        break;

        case QUATRE:
            ligne = 3;
        break;
    }

    int colonne = 0;

    switch (Case.c)
    {
        case A:
            colonne = 0;
        break;

        case B:
            colonne = 1;
        break;

        case C:
            colonne = 2;
        break;

        case D:
            colonne = 3;
        break;
    }

    return ligne*4+colonne;
}


int TTypePionToInt (TTypePion pion, bool * pieces)
{
    if(pion == PAVE)
    {
        if(pieces[0])
        {
            return 0;
        }
        if(pieces[1])
        {
            return 1;
        }
        perror("(pave) erreur dans la fonction TTypePionToInt");
        return -1; 
    }

    if(pion == CYLINDRE)
    {
        if(pieces[2])
        {
            return 2;
        }
        if(pieces[3])
        {
            return 3;
        }
        perror("(cylindre) erreur dans la fonction TTypePionToInt");
        return -1; 
    }

    if(pion == SPHERE)
    {
        if(pieces[4])
        {
            return 4;
        }
        if(pieces[5])
        {
            return 5;
        }
        perror("(sphere) erreur dans la fonction TTypePionToInt");
        return -1; 
    }

    if(pion == TETRAEDRE)
    {
        if(pieces[6])
        {
            return 6;
        }
        if(pieces[7])
        {
            return 7;
        }
        perror("(TETRAEDRE) erreur dans la fonction TTypePionToInt");
        return -1; 
    }
    perror("(pion inconnu) erreur dans la fonction TTypePionToInt");
    return -1;
}

//cette fonction modifie le plateau et les pièces dispo après un coup
void modifPlateauPieces (int **plateau, bool ** pieces , TCoupReq coup)
{
    int pion = TTypePionToInt(coup.pion.typePion, *pieces);

    (*pieces)[pion] = false;

    int Case = TCaseToInt(coup.posPion);
    

    if(coup.pion.coulPion == BLANC)
    {
        (*plateau)[Case] = pion+1;
    }
    else
    {
        (*plateau)[Case] = pion + 9;
    }
    

}

void affichePlateau (int * plateau)
{
    printf("////////////////////////////////\n");

    for(int i = 0; i <4 ; i++)
    {
        for(int j =0 ; j< 4 ; j++)
        {
            printf("%d ",plateau[i*4+j]);
        }
        printf("\n");
    }
    printf("////////////////////////////////\n");
}

