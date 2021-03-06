% La bilbliothèque de test unitaire
:-use_module(library(plunit)).


%////////////////////////// Initialisation /////////////////////

% codage du plateau :
%   0 : pas de piece sur la case
%   1 : pavé blanc sur la case
%   2 : cylindre blanc sur la case
%   3 : sphère blanche sur la case
%   4 : tétraèdre blanc sur la case
%   5 : pavé noir sur la case
%   6 : cylindre noir sur la case
%   7 : sphère noir sur la case
%   8 : tétraèdre noir sur la case
iniPlateau1([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]).

%codage du plateau 2:
%   le nombre représente le nombre de coups minimum qu'il reste à faire
%   faire à coté de la case pour gagner.
%   Donc au début tous les cases sont à 4
%   par exemple:
%       après le premier coup, tous les cases sur la ligne,
%       colonne, carrée du coup passent à 3.
%   Si il y a une piece sur la case , la valeur est négative

iniPlateau2([4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4]).

%pieces disponible:
    %1 disponible
    %0 déja joué
    %cases:
%       0 et 1 : les pavés
%       2 et 3 : les cylindres
%       4 et 5 : les sphères
%       6 et 7 : les tétraèdres
iniPieces([1,1,1,1,1,1,1,1]).

%////////////////////////// Codage des règles du jeu ///////////////////////

%avec Pi qui a pour codage les pieces du plateau
quadrupletGagnant([P1,P2,P3,P4]):-
    not(member(0,[P1,P2,P3,P4])),
    P1p is P1 mod 4, % on enleve la couleur
    P2p is P2 mod 4,
    P3p is P3 mod 4,
    P4p is P4 mod 4,
    14 =:= P1p*P1p + P2p*P2p + P3p*P3p + P4p*P4p.

% on regarde si une ligne est gagnante
gagne([C1,C2,C3,C4,_,_,_,_,_,_,_,_,_,_,_,_]):-
    quadrupletGagnant([C1,C2,C3,C4]).

gagne([_,_,_,_,C1,C2,C3,C4,_,_,_,_,_,_,_,_]):-
    quadrupletGagnant([C1,C2,C3,C4]).

gagne([_,_,_,_,_,_,_,_,C1,C2,C3,C4,_,_,_,_]):-
    quadrupletGagnant([C1,C2,C3,C4]).

gagne([_,_,_,_,_,_,_,_,_,_,_,_,C1,C2,C3,C4]):-
    quadrupletGagnant([C1,C2,C3,C4]).

% on regarde si une colonne est gagnante
gagne([C1,_,_,_,C2,_,_,_,C3,_,_,_,C4,_,_,_]):-
    quadrupletGagnant([C1,C2,C3,C4]).

gagne([_,C1,_,_,_,C2,_,_,_,C3,_,_,_,C4,_,_]):-
    quadrupletGagnant([C1,C2,C3,C4]).

gagne([_,_,C1,_,_,_,C2,_,_,_,C3,_,_,_,C4,_]):-
    quadrupletGagnant([C1,C2,C3,C4]).

gagne([_,_,_,C1,_,_,_,C2,_,_,_,C3,_,_,_,C4]):-
    quadrupletGagnant([C1,C2,C3,C4]).

%on regarde si un carré est gagnant
gagne([C1,C2,_,_,C3,C4,_,_,_,_,_,_,_,_,_,_]):-
    quadrupletGagnant([C1,C2,C3,C4]).

gagne([_,_,C3,C4,_,_,C1,C2,_,_,_,_,_,_,_,_]):-
    quadrupletGagnant([C1,C2,C3,C4]).

gagne([_,_,_,_,_,_,_,_,C1,C2,_,_,C3,C4,_,_]):-
    quadrupletGagnant([C1,C2,C3,C4]).

gagne([_,_,_,_,_,_,_,_,_,_,C3,C4,_,_,C1,C2]):-
    quadrupletGagnant([C1,C2,C3,C4]).

%cela peut être interessant de rechercher la partie nul
%dans le cas où on joue en second
nul(X):-
    not(member(0,X)),
    not(gagne(X)).

%bloquerR regarde si on est bloqué par les régles dans le triplet de case
bloquerR(X,1):-
    member(5,X).

bloquerR(X,2):-
    member(6,X).

bloquerR(X,3):-
    member(7,X).

bloquerR(X,4):-
    member(8,X).

bloquerR(X,5):-
    member(1,X).

bloquerR(X,6):-
    member(2,X).

bloquerR(X,7):-
    member(3,X).

bloquerR(X,8):-
    member(4,X).

% 1er paramètre : plateau ,
% 2ieme : coup,(pour la première case mettre 1 et pas 0)
% 3ieme = plateau résultat
% 4ieme = pieces dipo avant le coup
% 5ieme = pieces dispo après le coup
% 6ieme = plateau2
% 7ieme = plateau2 après le coup
jouerCoup(Pl1,[C,P],RPl1,PiecesDispo,RPiecesDispo,Pl2,RPl2):-
    helpJouerCoup(Pl1,[C,P],C,0,Li,Co,Ca,RPl1,Pl2,Pl2p,ILi,ICo,ICa),!,   
    not(bloquerR(Li,P)),
    not(bloquerR(Co,P)),
    not(bloquerR(Ca,P)),
    X is mod(P-1,4),
    modifPiecesDispo(PiecesDispo,X,RPiecesDispo),
    newModifPlateau2(Pl2p,RPl1,ILi,Pl2p2),
    newModifPlateau2(Pl2p2,RPl1,ICo,Pl2p3),
    newModifPlateau2(Pl2p3,RPl1,ICa,RPl2).






%la fonction suivante va modifier le plateau1 avec la pièce sur la case et va récupérer les cases liés au coup (ligne,colonne,carré) (valeurs et indices)
% 1er paramètre : plateau ,
% 2ieme : coup,(pour la première case mettre 0
% 3ieme : identifie la case sur le plateau (appelé avec C lors du premier appel)
% 4ieme : permet de savoir où on est sur le plateau dans la fonction (appelé avec 1 lors du premier appel)
% 5ieme : valeurs des cases qui peuvent bloquer en ligne 
% 6ieme : valeurs des cases qui peuvent bloquer en colonne 
% 7ieme : valeurs des cases qui peuvent bloquer en carré 
% 8ieme = plateau résultat
% 9ieme = plateau2
% 10ieme = plateau2 avec comme seul modification un -1 sur la case joué (il reste d'autres modifs à faire après la fonction (diminuer la valeur des auters cases liés (ligne,colonne,carré)))
% 11ieme : indice des cases qui peuvent bloquer en ligne + valeur de la piece
% 12ieme : indice des cases qui peuvent bloquer en colonne + valeur de la piece
% 13ieme : indice des cases qui peuvent bloquer en carré + valeur de la piece

%cas de la denière case plateau
%helpJouerCoup([],[_,_],_,17,[],[],[],[],[]).
helpJouerCoup([],[_,_],_,16,[],[],[],[],[],[],[],[],[]).


%cas où on est sur la case pointé par le coup
helpJouerCoup([0|TPl1],[C,P],0,CPlateau,Li,Co,Ca,[P|TPl1],[_|TPl2],[-1|TPl2],ILi,ICo,ICa):-
    CPlateau2 is CPlateau +1,
    helpJouerCoup(TPl1,[C,P],-1,CPlateau2,Li,Co,Ca,TPl1,TPl2,TPl2,ILi,ICo,ICa).

%ligne
helpJouerCoup([HPl1|TPl1],[C,P],Compt,CPlateau,[HPl1|TLi],Co,Ca,[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],[CPlateau|TILi],ICo,ICa):-
    Q1 is div(CPlateau,4),
    Q2 is div(C,4),
    Q1 == Q2,
    %Compt2 is Compt -1,
    %CPlateau2 is CPlateau + 1 ,
    %helpJouerCoup(TPl1,[C,P],Compt2,CPlateau2,TLi,Co,Ca,TRPl1,TPl2,TRPl2,TILi,ICo,ICa).
    %il faut vérifier si la case n'est pas dans le carré aussi
    estDansCarre([HPl1|TPl1],[C,P],Compt,CPlateau,TLi,Co,Ca,[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],TILi,ICo,ICa).

%colonne
helpJouerCoup([HPl1|TPl1],[C,P],Compt,CPlateau,Li,[HPl1|TCo],Ca,[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],ILi,[CPlateau|TICo],ICa):-
    R1 is mod(CPlateau,4),
    R2 is mod(C,4),
    R1 == R2,
    %Compt2 is Compt -1,
    %CPlateau2 is CPlateau +1,
    %helpJouerCoup(TPl1,[C,P],Compt2,CPlateau2,Li,TCo,Ca,TRPl1,TPl2,TRPl2,ILi,TICo,ICa).
    estDansCarre([HPl1|TPl1],[C,P],Compt,CPlateau,Li,TCo,Ca,[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],ILi,TICo,ICa).


% carré cas en haut à gauche
helpJouerCoup([HPl1|TPl1],[C,P],Compt,CPlateau,Li,Co,[HPl1|TCa],[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],ILi,ICo,[CPlateau|TICa]):-
    estDansCarre([HPl1|TPl1],[C,P],Compt,CPlateau,Li,Co,[HPl1|TCa],[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],ILi,ICo,[CPlateau|TICa]).

% carré cas en haut à droite
helpJouerCoup([HPl1|TPl1],[C,P],Compt,CPlateau,Li,Co,[HPl1|TCa],[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],ILi,ICo,[CPlateau|TICa]):-
    estDansCarre([HPl1|TPl1],[C,P],Compt,CPlateau,Li,Co,[HPl1|TCa],[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],ILi,ICo,[CPlateau|TICa]).

% carré cas en bas à gauche
helpJouerCoup([HPl1|TPl1],[C,P],Compt,CPlateau,Li,Co,[HPl1|TCa],[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],ILi,ICo,[CPlateau|TICa]):-
    estDansCarre([HPl1|TPl1],[C,P],Compt,CPlateau,Li,Co,[HPl1|TCa],[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],ILi,ICo,[CPlateau|TICa]).

% carré cas en bas à droite
helpJouerCoup([HPl1|TPl1],[C,P],Compt,CPlateau,Li,Co,[HPl1|TCa],[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],ILi,ICo,[CPlateau|TICa]):-
    estDansCarre([HPl1|TPl1],[C,P],Compt,CPlateau,Li,Co,[HPl1|TCa],[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],ILi,ICo,[CPlateau|TICa]).

%autre cas
helpJouerCoup([HPl1|TPl1],[C,P],Compt,CPlateau,Li,Co,TCa,[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],ILi,ICo,TICa):-
    Compt2 is Compt -1,
    CPlateau2 is CPlateau + 1,
    helpJouerCoup(TPl1,[C,P],Compt2,CPlateau2,Li,Co,TCa,TRPl1,TPl2,TRPl2,ILi,ICo,TICa).

% carré cas en haut à gauche
estDansCarre([HPl1|TPl1],[C,P],Compt,CPlateau,Li,Co,[HPl1|TCa],[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],ILi,ICo,[CPlateau|TICa]):-
    divmod(CPlateau,4,Q1,R1),
    divmod(C,4,Q2,R2),
    Q2 <2,
    R2 < 2,
    Q1 < 2,
    R1 < 2,
    Compt2 is Compt -1,
    CPlateau2 is CPlateau + 1,
    helpJouerCoup(TPl1,[C,P],Compt2,CPlateau2,Li,Co,TCa,TRPl1,TPl2,TRPl2,ILi,ICo,TICa).


% carré cas en haut à droite
estDansCarre([HPl1|TPl1],[C,P],Compt,CPlateau,Li,Co,[HPl1|TCa],[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],ILi,ICo,[CPlateau|TICa]):-
    divmod(CPlateau,4,Q1,R1),
    divmod(C,4,Q2,R2),
    Q2 <2,
    R2 > 1,
    Q1 < 2,
    R1 > 1,
    Compt2 is Compt -1,
    CPlateau2 is CPlateau + 1,
    helpJouerCoup(TPl1,[C,P],Compt2,CPlateau2,Li,Co,TCa,TRPl1,TPl2,TRPl2,ILi,ICo,TICa).

% carré cas en bas à gauche
estDansCarre([HPl1|TPl1],[C,P],Compt,CPlateau,Li,Co,[HPl1|TCa],[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],ILi,ICo,[CPlateau|TICa]):-
    divmod(CPlateau,4,Q1,R1),
    divmod(C,4,Q2,R2),
    Q2 > 1,
    R2 < 2,
    Q1 > 1,
    R1 < 2,
    Compt2 is Compt -1,
    CPlateau2 is CPlateau + 1,
    helpJouerCoup(TPl1,[C,P],Compt2,CPlateau2,Li,Co,TCa,TRPl1,TPl2,TRPl2,ILi,ICo,TICa).


% carré cas en bas à droite

estDansCarre([HPl1|TPl1],[C,P],Compt,CPlateau,Li,Co,[HPl1|TCa],[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],ILi,ICo,[CPlateau|TICa]):-
    divmod(CPlateau,4,Q1,R1),
    divmod(C,4,Q2,R2),
    Q2 > 1,
    R2 > 1,
    Q1 > 1,
    R1 > 1,
    Compt2 is Compt -1,
    CPlateau2 is CPlateau + 1,
    helpJouerCoup(TPl1,[C,P],Compt2,CPlateau2,Li,Co,TCa,TRPl1,TPl2,TRPl2,ILi,ICo,TICa).

% cas où on est pas dans un carré mais il faut rappeler helpJouer pour finir le job (correspond à 75% des cas )
estDansCarre([HPl1|TPl1],[C,P],Compt,CPlateau,Li,Co,Ca,[HPl1|TRPl1],[HPl2|TPl2],[HPl2|TRPl2],ILi,ICo,ICa):-
    Compt2 is Compt -1,
    CPlateau2 is CPlateau + 1,
    helpJouerCoup(TPl1,[C,P],Compt2,CPlateau2,Li,Co,Ca,TRPl1,TPl2,TRPl2,ILi,ICo,ICa).


%le 2ieme argument doit être compris entre 0 et 3 (attention avec 0 pour le pavé (donc faire -1 pui mod 4 our le premier appel))
modifPiecesDispo([1|T],0,[0|T]).

modifPiecesDispo([0|[1|T]],0,[0|[0|T]]).

modifPiecesDispo([H|[H2|T]],Piece,[H|[H2|TRes]]):-
    X is Piece-1,
    modifPiecesDispo(T,X,TRes).




%/////////////////////////////////// choix du coup /////////////////////////////////

%tout les fonctions ici sont à améliorer (ainsi que la représentation du deuxiéme plateau , il faut y mettre plus d'info)
%le but est pour l'instant d'avoir un projet fonctionnel , l'ia sera améliorer une fois que le projet marchera complétement

%pour la pièce

%on choisi en priorité une piéce qui est encore en double (choixPieceDispo1), et si il n'y plus de piéces en double on choisit n'importe laquelle (choixPieceDispo2)
%la liste des piéces (deuxième paramètre) est trié du plus prioritaire au moin prioritaire
choixPiecesDispo([0,0,0,0,0,0,0,0],[],_).

choixPiecesDispo(PiecesDispo,[H|TPiecesChoisi],Noir):-
    choixPieceDispo1(PiecesDispo,0,H,RPD,Noir),
    choixPiecesDispo(RPD,TPiecesChoisi,Noir).

choixPiecesDispo(PiecesDispo,[H|TPiecesChoisi],Noir):-
    choixPieceDispo2(PiecesDispo,0,H,RPD,Noir),
    choixPiecesDispo(RPD,TPiecesChoisi,Noir).

%le premier paramètre est le tableau des pièces disponibles
%lors du premier appel à cette fonction , le deuxiéme paramètre vaut 0
% le troisième est la piecé retourné (1 pour le pavé blanc et 5 pour le pavé noir)
%le quatrième est les piecès dispo avec la piéce choisit qui devient indisponible
% le dernier paramètre indique la couleur , 1 pour noir et 0 pour blanc
choixPieceDispo1([1|[1|T]],Compt,Piece,[0|[1|T]],Noir):-
    Piece is 1+Compt + Noir * 4.
    

choixPieceDispo1([P1|[P2|T]],Compt,Piece,[P1|[P2|TR]],Noir):-
    Compt2 is Compt +1 ,
    choixPieceDispo1(T,Compt2,Piece,TR,Noir).

%on part du principe que on modifie les pièces seuelement avec la fonction modifPiecesDispo fait précédemment.
%cela implique que si un type de pièce n'est pas en double , alors le tableau des pièces disponible représente ca avec un 0 puis un 1. (on suppose donc que l'inverse n'est pas possible)
choixPieceDispo2([0|[1|T]],Compt,Piece,[0|[0|T]],Noir):-
    Piece is 1+Compt + Noir * 4.
    

choixPieceDispo2([0|[0|T]],Compt,Piece,[0|[0|TR]],Noir):-
    Compt2 is Compt +1 ,
    choixPieceDispo2(T,Compt2,Piece,TR,Noir).

%pour la case 

%tableau des cases à cibler en priorité (on connait grâce au tableau 2)

choixCases1([1|TPl2],Compt,Compt,[-1|TPl2]).

choixCases1([HPl2|TPl2],Compt,Case,[HPl2|TRPl2]):-
    Compt2 is Compt +1,
    choixCases1(TPl2,Compt2,Case,TRPl2).

choixCases2([3|TPl2],Compt,Compt,[-1|TPl2]).

choixCases2([HPl2|TPl2],Compt,Case,[HPl2|TRPl2]):-
    Compt2 is Compt +1,
    choixCases2(TPl2,Compt2,Case,TRPl2).

choixCases3([4|TPl2],Compt,Compt,[-1|TPl2]).

choixCases3([HPl2|TPl2],Compt,Case,[HPl2|TRPl2]):-
    Compt2 is Compt +1,
    choixCases3(TPl2,Compt2,Case,TRPl2).

choixCases4([X|TPl2],Compt,Compt,[-1|TPl2]):-
    X > 10. % la valeur pour inutile est 42 je laisse comme ça car il faut de tout facon changer en plusieurs niveaux d'inutilité

choixCases4([HPl2|TPl2],Compt,Case,[HPl2|TRPl2]):-
    Compt2 is Compt +1,
    choixCases4(TPl2,Compt2,Case,TRPl2).

%là on risque fortement de perdre mais bon au moin on perd en jouant (si on choisit pas une case c'est loose aussi)
choixCases5([2|TPl2],Compt,Compt,[-1|TPl2]).

choixCases5([HPl2|TPl2],Compt,Case,[HPl2|TRPl2]):-
    Compt2 is Compt +1,
    choixCases5(TPl2,Compt2,Case,TRPl2).

choixCases(Pl2,[]):-
    %nospyall,nodebug,notrace,
    tousNegatifs(Pl2).

choixCases(Pl2,[H|CasesChoisi]):-
    choixCases1(Pl2,0,H,RPl2),
    choixCases(RPl2,CasesChoisi).

choixCases(Pl2,[H|CasesChoisi]):-
    choixCases2(Pl2,0,H,RPl2),
    choixCases(RPl2,CasesChoisi).

choixCases(Pl2,[H|CasesChoisi]):-
    choixCases3(Pl2,0,H,RPl2),
    choixCases(RPl2,CasesChoisi).

choixCases(Pl2,[H|CasesChoisi]):-
    choixCases4(Pl2,0,H,RPl2),
    choixCases(RPl2,CasesChoisi).

choixCases(Pl2,[H|CasesChoisi]):-
    choixCases5(Pl2,0,H,RPl2),
    choixCases(RPl2,CasesChoisi).

tousNegatifs([]).

tousNegatifs([H|T]):-
    H<0,
    tousNegatifs(T).

% construction du coup avec récupération des plateau après le coup construit
choixCoupEtJoue(Pl1,Pl2,PiecesDispo,C,P,RPl1,RPl2,RPD,Noir):-
    choixPiecesDispo(PiecesDispo,PiecesChoisi,Noir),
    choixCases(Pl2,CasesChoisi),
    prioriteCasesSurPieces(Pl1,Pl2,PiecesDispo,PiecesChoisi,CasesChoisi,PiecesChoisi,C,P,RPl1,RPl2,RPD).

%cette priotité est pour simplifier pour la première version de l'ia ,
% en vrai quand il ne reste plus qu'une pièce pour un type , il vaut mieu privilégier la pièce parfois
prioriteCasesSurPieces(Pl1,Pl2,PiecesDispo,_,[HC|_],[HP|_],HC,HP,RPl1,RPl2,RPD):-
    jouerCoup(Pl1,[HC,HP],RPl1,PiecesDispo,RPD,Pl2,RPl2). % on joue le coup si on peut

prioriteCasesSurPieces(Pl1,Pl2,PiecesDispo,PiecesChoisi,[HC|TC],[_|TP],C,P,RPl1,RPl2,RPD):-
    %not(jouerCoup(Pl1,[HC,HP],_,PiecesDispo,_,Pl2,_)),
    % pas besoin de l'appel à jouer au dessus , car on sait que on ne peut pas jouer l'appel a été fait au dessus
    prioriteCasesSurPieces(Pl1,Pl2,PiecesDispo,PiecesChoisi,[HC|TC],TP,C,P,RPl1,RPl2,RPD).

prioriteCasesSurPieces(Pl1,Pl2,PiecesDispo,PiecesChoisi,[_|TC],[],C,P,RPl1,RPl2,RPD):-
    prioriteCasesSurPieces(Pl1,Pl2,PiecesDispo,PiecesChoisi,TC,PiecesChoisi,C,P,RPl1,RPl2,RPD).



%parcour en profondeur avec heuristique pour une partie gagné
%avant dernier paramètre , compteur , pour savoir si c'est notre tour (utiliser 0 au premier appel)
%dernier paramètre : la couleur , 0 pour blanc et 1 pour noir
chercheGagne(Coups,Coups,CoupsA,CoupsA,[HPl1|TPl1],[HPl1|TPl1],X1,X1,X2,X2,X3,X3,Compt,_):-
    Test is Compt mod 2,
    Test == 1, % on regarde si c'est le tour de l'adversaire (et que la configuration est gagnante sans qu'il est joué)
    gagne(HPl1).

chercheGagne(Coups,Coups,CoupsA,CoupsA,[HPl1|TPl1],[HPl1|TPl1],[HPD|TPD],[HPD|TPD],[HPDA|TPDA],[HPDA|TPDA],[HPl2|TPl2],[HPl2|TPl2],Compt,_):-
    Test is Compt mod 2,
    Test == 1, % on regarde si c'est le tour de l'adbersaire (et que la configuration est gagnante sans qu'il est joué)
    % on regarde si l'adversaire est bloquer
    % je pense que c'est peut être trop gourmand.
    % Si c'est bien le cas voir entre enlver cette état final ou trouver un meilleur algo pour savoir si le plateau est bloquant pour les pièces restantes.
    casesVides(HPl1,CasesVides),
    bloquerAll(HPl1,CasesVides,HPDA,CasesVides).

chercheGagne([[C,P]|TC],Res1,X1,Res2,[HPl1|TPl1],Res3,[HPD|TPD],Res4,X2,Res5,[HPl2|TPl2],Res6,Compt,Noir):-
    %nospyall,notrace,nodebug,
    Test is Compt mod 2,
    Test == 0,
    member(1,HPD), % on vérifie qu'il reste une pièce à jouer
    choixCoupEtJoue(HPl1,HPl2,HPD,C,P,RPl1,RPl2,RPD,Noir),
    Compt2 is Compt + 1,
    Noir2 is (Noir + 1) mod 2,
    chercheGagne([_,[C,P]|TC],Res1,X1,Res2,[RPl1,HPl1|TPl1],Res3,[RPD,HPD|TPD],Res4,X2,Res5,[RPl2,HPl2|TPl2],Res6,Compt2,Noir2).

chercheGagne(X1,Res1,[[CA,PA]|TCA],Res2,[HPl1|TPl1],Res3,X2,Res4,[HPDA|TPDA],Res5,[HPl2|TPl2],Res6,Compt,Noir):-
    Test is Compt mod 2,
    Test == 1, % tour adverse
    member(1,HPDA), % on vérifie qu'il reste une pièce à jouer
    %spy(choixCoupEtJoue),
    choixCoupEtJoue(HPl1,HPl2,HPDA,CA,PA,RPl1,RPl2,RPDA,Noir), % bon, on va dire que l'adversaire utilise la même heuristique
    Compt2 is Compt + 1,
    Noir2 is (Noir + 1) mod 2,
    %spy(chercheGagne),
    chercheGagne(X1,Res1,[_,[CA,PA]|TCA],Res2,[RPl1,HPl1|TPl1],Res3,X2,Res4,[RPDA,HPDA|TPDA],Res5,[RPl2,HPl2|TPl2],Res6,Compt2,Noir2).


%parcours en profondeur qui cherche la partie nul, à utiliser si on joue en deuxième.
chercheNul(Coups,Coups,CoupsA,CoupsA,[HPl1|TPl1],[HPl1|TPl1],X1,X1,X2,X2,X3,X3,_,_):-
    nul(HPl1).

chercheNul([[C,P]|TC],Res1,X1,Res2,[HPl1|TPl1],Res3,[HPD|TPD],Res4,X2,Res5,[HPl2|TPl2],Res6,Compt,Noir):-
    Test is Compt mod 2,
    Test == 0,
    member(1,HPD),
    choixCoupEtJoue(HPl1,HPl2,HPD,C,P,RPl1,RPl2,RPD,Noir),
    Compt2 is Compt + 1,
    Noir2 is (Noir + 1) mod 2,
    chercheNul([_,[C,P]|TC],Res1,X1,Res2,[RPl1,HPl1|TPl1],Res3,[RPD,HPD|TPD],Res4,X2,Res5,[RPl2,HPl2|TPl2],Res6,Compt2,Noir2).

chercheNul(X1,Res1,[[CA,PA]|TCA],Res2,[HPl1|TPl1],Res3,X2,Res4,[HPDA|TPDA],Res5,[HPl2|TPl2],Res6,Compt,Noir):-
    Test is Compt mod 2,
    Test == 1, 
    member(1,HPDA),
    choixCoupEtJoue(HPl1,HPl2,HPDA,CA,PA,RPl1,RPl2,RPDA,Noir), % bon, on va dire que l'adversaire utilise la même heuristique
    Compt2 is Compt + 1,
    Noir2 is (Noir + 1) mod 2,
    chercheNul(X1,Res1,[_,[CA,PA]|TCA],Res2,[RPl1,HPl1|TPl1],Res3,X2,Res4,[RPDA,HPDA|TPDA],Res5,[RPl2,HPl2|TPl2],Res6,Compt2,Noir2).





casesVides(Pl1,[C|T]):-
    nth0(C,Pl1,0),!, 
    select(0, Pl1,1, RPl1),!,
    casesVides(RPl1,T).
    

casesVides(_,[]).

%regarde si le plateau rend les pièces dispo bloqués.
bloquerAll(_,[],[],_).

bloquerAll(Pl1,[C|T],[HPD|TPD],CasesVides):-
    not(verifJouerCoup(Pl1,[C,HPD])),!,
    bloquerAll(Pl1,T,[HPD|TPD],CasesVides).

bloquerAll(Pl1,[],[_|TPD],CasesVides):-
    bloquerAll(Pl1,CasesVides,TPD,CasesVides).


% prédicat jouerCoup avec juste le coup joué sur le plateau1 (utiliser dans bloquerAll)
verifJouerCoup(Pl1,[C,P]):-
    helpJouerCoup(Pl1,[C,P],C,0,Li,Co,Ca,_,_,_,_,_,_),!,
    not(bloquerR(Li,P)),
    not(bloquerR(Co,P)),
    not(bloquerR(Ca,P)).



% en fait il aurait été peut être plus simple de faire jouerCoup avecles fonctions qui suit, 
% donnes les indices des cases de la ligne 
indicesCasesLigne(I,Li):-
    Q is div(I,4),
    L1 is Q*4,
    L2 is Q*4 +1,
    L3 is Q*4 +2,
    L4 is Q*4 +3,
    Li=[L1,L2,L3,L4].

indicesCasesColonne(I,Co):-
    R is I mod 4,
    C1 is R,
    C2 is R+4,
    C3 is R+8,
    C4 is R+12,
    Co=[C1,C2,C3,C4].

% cas du carré en haut à gauche
indicesCasesCarre(I,Ca):-
    divmod(I,4,Q1,R1),
    Q1 < 2,
    R1 < 2,
    Ca=[0,1,4,5].

% cas du carré en haut à droite
indicesCasesCarre(I,Ca):-
    divmod(I,4,Q1,R1),
    Q1 < 2,
    R1 > 1,
    Ca=[2,3,6,7].

% cas du carré en bas à gauche
indicesCasesCarre(I,Ca):-
    divmod(I,4,Q1,R1),
    Q1 > 1,
    R1 < 2,
    Ca=[8,9,12,13].

% cas du carré en bas à droite
indicesCasesCarre(I,Ca):-
    divmod(I,4,Q1,R1),
    Q1 > 1,
    R1 > 1,
    Ca=[10,11,14,15].


tetraedre([],Res,Res).

tetraedre([H|T],Compt,Res):-
    H \= 0, %0 est pour la case vide au départ
    X is H mod 4, % on enlève la couleur
    X = 0,
    Compt2 is Compt + 1,
    tetraedre(T,Compt2,Res).

tetraedre([_|T],Compt,Res):-
    tetraedre(T,Compt,Res).

pave([],Res,Res).

pave([H|T],Compt,Res):-
    X is H mod 4, % on enlève la couleur
    X = 1,
    Compt2 is Compt + 1,
    pave(T,Compt2,Res).

pave([_|T],Compt,Res):-
    pave(T,Compt,Res).



cylindre([],Res,Res).

cylindre([H|T],Compt,Res):-
    X is H mod 4, % on enlève la couleur
    X = 2,
    Compt2 is Compt + 1,
    cylindre(T,Compt2,Res).

cylindre([_|T],Compt,Res):-
    cylindre(T,Compt,Res).

sphere([],Res,Res).

sphere([H|T],Compt,Res):-
    X is H mod 4, % on enlève la couleur
    X = 3,
    Compt2 is Compt + 1,
    sphere(T,Compt2,Res).

sphere([_|T],Compt,Res):-
    sphere(T,Compt,Res).


% donne une valeur d'une composion de 4 pièces
valeurCompo(Pieces,Valeur):-
    tetraedre(Pieces,0,V1),
    V1 < 2, % on vérifie qu'il n'y est pas 2 tétraèdre
    %spy(pave),
    pave(Pieces,0,V2),
    %nospyall,nodebug,notrace,
    V2 < 2,
    cylindre(Pieces,0,V3),
    V3 < 2,
    sphere(Pieces,0,V4),
    V4 < 2,
    %write("Pieces = "),
    %write(Pieces),
    %write(" V2 = "),
    %write(V2),
    %writef("\n"),
    Valeur is 4 - V1 - V2 -V3 - V4.

valeurCompo(_,_,42). %si il y a deux fois la même piece dans une compo (pour indiquer que la valeur de la compo est faible on va mettre 42)

minimumListe([],Res,Res).

minimumListe([H|T],Min,Res):-
    H < Min,
    minimumListe(T,H,Res).

minimumListe([_|T],Min,Res):-
    minimumListe(T,Min,Res).

%la meilleur valeur Compo (le minimum donc) (entre la compo ligne , colonne et carrée)
meilleurValeurCompo(V1,V2,V3,Res):-
    minimumListe([V1,V2,V3],V1,Res).

%fonction appellé dans modifPlateau2 qui permet de donner une valeur aux cases voisines de la case ciblé pendant le coup (ligne,colonne,carrée)
%ici on donne un indice de la case voisine
%si un 42 apparait cela veut dire que la case est libre mais inutile
valeurCasePl2(Pl1,I,Res):-
    indicesCasesLigne(I,[L1,L2,L3,L4]),
    indicesCasesColonne(I,[Co1,Co2,Co3,Co4]),
    indicesCasesCarre(I,[Ca1,Ca2,Ca3,Ca4]),
    %nospyall(),nodebug,notrace,
    %spy(valeurCompo),
    nth0(L1,Pl1,VL1),
    nth0(L2,Pl1,VL2),
    nth0(L3,Pl1,VL3),
    nth0(L4,Pl1,VL4),
    nth0(Co1,Pl1,VCo1),
    nth0(Co2,Pl1,VCo2),
    nth0(Co3,Pl1,VCo3),
    nth0(Co4,Pl1,VCo4),
    nth0(Ca1,Pl1,VCa1),
    nth0(Ca2,Pl1,VCa2),
    nth0(Ca3,Pl1,VCa3),
    nth0(Ca4,Pl1,VCa4),
    %write("///////////////////"),writef("\n"),
    %write([VL1,VL2,VL3,VL4]),write([VCo1,VCo2,VCo3,VCo4]),write([VCa1,VCa2,VCa3,VCa4]),writef("\n"),
    %write("///////////////////"),writef("\n"),
    valeurCompo([VL1,VL2,VL3,VL4],VLi),
    %writef("\n li : "),write(VLi),writef("\n"),
    valeurCompo([VCo1,VCo2,VCo3,VCo4],VCo),
    %writef("\n co : "),write(VCo),writef("\n"),
    valeurCompo([VCa1,VCa2,VCa3,VCa4],VCa),
    %writef("\n ca : "),write(VCa),writef("\n"),
    
    meilleurValeurCompo(VLi,VCo,VCa,Res).


%le 2 paramétre représente un des 3 triplets d'indices récupérer dans le prédicat helpJouerCoup (ILi,ICo,ICa)
newModifPlateau2(Pl2,_,[],Pl2).

newModifPlateau2(Pl2,Pl1,[H|T],Res):-
    nth0(H,Pl2,Vact),
    Vact > 0, % si la valeur est négative , cela veut dire que la case est occupé et donc il ne faut pas la changer
    valeurCasePl2(Pl1,H,Vnew),
    modifCasePl2(Pl2,0,H,Vnew,RPl2),
    newModifPlateau2(RPl2,Pl1,T,Res).
    
newModifPlateau2(Pl2,Pl1,[H|T],Res):-
    nth0(H,Pl2,Vact),
    Vact < 0, % je pense qu'il n'y a pas besoin de tester cela et que c'est forcément le cas si on rentre dans ce prédicat mais on va le garder par mesure de sureté
    newModifPlateau2(Pl2,Pl1,T,Res).

modifCasePl2([_|T],Compt,Compt,Val,[Val|T]).

modifCasePl2([H|T],Compt,Indice,Val,[H|T2]):-
    Compt2 is Compt + 1,
    modifCasePl2(T,Compt2,Indice,Val,T2).


%jouerCoup([1+0+0*4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 1+0+1*4], _6452, [1, 1, 1, 1, 1, 1, 1, 1], _6456, [-1, 3, 3, 3, 3, 3, 4, 4, 3, 4, 4, 4, 3, 4, 4, 4], _6460)
%[-2, -1, 2, 2, 2, 2, 4, 4, 3, 3, 4, 4, 3, 3, 4, 4]

%jouerCoup([1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],[1,5],RPl1,[1, 1, 1, 1, 1, 1, 1, 1],RPD,[-1, 3, 3, 3, 3, 3, 4, 4, 3, 4, 4, 4, 3, 4, 4, 4],RPl2)

%jouerCoup([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,1],RPL1,[1,1,1,1,1,1,1,1],RPD,[4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4],RPL2).

%chercheGagne([[C,P]],Res1,[[Ca,Pa]],Res2,[[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]],Res3,[[1,1,1,1,1,1,1,1]],Res4,[[1,1,1,1,1,1,1,1]],Res5,[[4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4]],Res6,0,0).

%newModifPlateau2([2, -1, 2, 2, 2, 2, 4, 4, -1, 4, 4, 4, 3, 4, 4, 4], [1, 6, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0], [9, 10, 11], _552)



%choixCoupEtJoue([1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[-1,3,3,3,3,3,4,4,3,4,4,4,3,4,4,4], [1,1,1,1,1,1,1,1],1,6,F,G,H,1).



