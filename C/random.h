#include "protocole.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>



/************* gestion des la construction des coups ***************/

typedef struct {
  int propCoup; 
  int estBloque;     
  int typePion;         
  int lignePion;       
  int colonnePion;        
} coupIA;



TCoupReq buildCoup (TLg l, TCol c, int p, int bloque, int propCoup, TIdReq idRequest, int numPartie, TCoul couleur);

coupIA buildCoupIA (int bloque, int p, TLg l, TCol c, int propCoup);

/************ gestions coups random **************/

struct tab{
    int * tab;
    int size;
    int capacity;
};

void addTab (struct tab * tab, int value);

int * iniPlateau ();

struct tab tablePositionsPiece( int * plateau , int piece , TCoul couleurAdv);

int * jouerRandom (int * plateau , bool * pieces,TCoul coulAdv);

bool * iniPiecesDispo ();

int randomPieceDispo (bool * tab);

TTypePion intToTTypePion (int piece);

TCase intToTCase (int Case);

bool estPave(int * plateau , int Case);

bool estCylindre(int * plateau , int Case);

bool estSphere(int * plateau , int Case);

bool estTetraedre(int * plateau , int Case);

bool gagneLigne(int *plateau);

bool gagne (int *plateau);

bool gagneColonne (int *plateau);

bool gagneCarree (int * plateau);

bool gagne (int *plateau);

TCoupReq randomCoup (int * plateau , bool * pieces ,TIdReq idRequest, int numPartie, TCoul couleur);

int TCaseToInt(TCase Case);

int TTypePionToInt (TTypePion pion, bool * pieces);

void modifPlateauPieces (int **plateau, bool ** pieces , TCoupReq coup);

void affichePlateau (int * plateau);


