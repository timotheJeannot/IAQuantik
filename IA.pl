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
    14 == P1p*P1p + P2p*P2p + P3p*P3p + P4p*P4p.

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
    helpJouerCoup(Pl1,[C,P],C,1,[Li,Co,Ca],RPl1,Pl2,Pl2p,I),
    not(bloquerR(Li,P)),
    not(bloquerR(Co,P)),
    not(bloquerR(Ca,P)),
    X is mod(P-1,4),
    modifPiecesDispo(PiecesDispo,X,RPiecesDispo),
    modifPlateau2(Pl2p,I,RPl2).



%la fonction suivante va modifier le plateau1 avec la pièce sur la case et va récupérer les cases liés au coup (ligne,colonne,carré) (valeurs et indices)
% 1er paramètre : plateau ,
% 2ieme : coup,(pour la première case mettre 1 et pas 0)
% 3ieme : identifie la case sur le plateau (appelé avec C lors du premier appel)
% 4ieme : permet de savoir où on est sur le plateau dans la fonction (appelé avec 1 lors du premier appel)
% 5ieme = cases qui peuvent bloquer (ligne , colonne, carré) ,
% 6ieme = plateau résultat
% 7ieme = plateau2
% 8ieme = plateau2 avec comme seul modification un -1 sur la case joué (il reste d'autres modifs à faire après la fonction (diminuer la valeur des auters cases liés (ligne,colonne,carré)))
% 9ieme = indices des cases du 5ieme paramètres

%cas de la denière case plateau
helpJouerCoup([],[_,_],_,17,[],[],[],[],[]).
%jouerCoup([],[_,P],_,17,_,[],PiecesDispo,RPiecesDispo,Pl2,RPl2,I)=-
    %not(bloquerR(Li,P)),
    %not(bloquerR(Co,P)),
    %not(bloquerR(Ca,P)),
    %X is mod(P-1,4),
    %modifPiecesDispo(PiecesDispo,X,RPiecesDispo),
    %modifPlateau2(PL2,I,RPl2).

%cas où on est sur la case pointé par le coup
helpJouerCoup([0|TPl1],[C,P],0,CPlateau,X,[P|TRPl1],[_|TPl2],[-1|TRPl2],I):-
    CPlateau2 is CPlateau +1,
    helpJouerCoup(TPl1,[C,P],-1,CPlateau2,X,TRPl1,TPl2,TRPl2,I).

%lignes
helpJouerCoup([HPl1|TPl1],[C,P],Compt,CPlateau,[[HPl1|TLi],Co,Ca],[HPl1|TRPl1],Pl2,RPl2,[[HIl1|TILi],ICo,ICa]):-
    Q1 is div(CPlateau,4),
    Q2 is div(C,4),
    Q1 == Q2,
    Compt2 is Compt -1,
    CPlateau2 is CPlateau + 1 ,
    HIl1 is CPlateau -1, % indice de la case
    helpJouerCoup(TPl1,[C,P],Compt2,CPlateau2,[TLi,Co,Ca],TRPl1,Pl2,RPl2,[TILi,ICo,ICa]).

%colonnes
helpJouerCoup([HPl1|TPl1],[C,P],Compt,CPlateau,[Li,[HPl1|TCo],Ca],[HPl1|TRPl1],Pl2,RPl2,[ILi,[HICo|TICo],ICa]):-
    R1 is mod(CPlateau,4),
    R2 is mod(C,4),
    R1 == R2,
    Compt2 is Compt -1,
    CPlateau2 is CPlateau +1,
    HICo is CPlateau -1,
    helpJouerCoup(TPl1,[C,P],Compt2,CPlateau2,[Li,TCo,Ca],TRPl1,Pl2,RPl2,[ILi,TICo,ICa]).

% carré cas en haut à gauche
helpJouerCoup([HPl1|TPl1],[C,P],Compt,CPlateau,[Li,Co,[HPl1|TCa]],[HPl1|TRPl1],Pl2,RPl2,[ILi,ICo,[HICa|TICa]]):-
    divmod(CPlateau,4,Q1,R1),
    divmod(C,4,Q2,R2),
    Q2 <2,
    R2 < 2,
    Q1 < 2,
    R1 < 2,
    Compt2 is Compt -1,
    CPlateau2 is CPlateau + 1,
    HICa is CPlateau -1,
    helpJouerCoup(TPl1,[C,P],Compt2,CPlateau2,[Li,Co,TCa],TRPl1,Pl2,RPl2,[ILi,ICo,TICa]).

% carré cas en haut à droite
helpJouerCoup([HPl1|TPl1],[C,P],Compt,CPlateau,[Li,Co,[HPl1|TCa]],[HPl1|TRPl1],Pl2,RPl2,[ILi,ICo,[HICa|TICa]]):-
    divmod(CPlateau,4,Q1,R1),
    divmod(C,4,Q2,R2),
    Q2 <2,
    R2 > 1,
    Q1 < 2,
    R1 > 1,
    Compt2 is Compt -1,
    CPlateau2 is CPlateau + 1,
    HICa is CPlateau -1,
    helpJouerCoup(TPl1,[C,P],Compt2,CPlateau2,[Li,Co,TCa],TRPl1,Pl2,RPl2,[ILi,ICo,TICa]).

% carré cas en bas à gauche
helpJouerCoup([HPl1|TPl1],[C,P],Compt,CPlateau,[Li,Co,[HPl1|TCa]],[HPl1|TRPl1],Pl2,RPl2,[ILi,ICo,[HICa|TICa]]):-
    divmod(CPlateau,4,Q1,R1),
    divmod(C,4,Q2,R2),
    Q2 > 1,
    R2 < 2,
    Q1 > 1,
    R1 < 2,
    Compt2 is Compt -1,
    CPlateau2 is CPlateau + 1,
    HICa is CPlateau -1,
    helpJouerCoup(TPl1,[C,P],Compt2,CPlateau2,[Li,Co,TCa],TRPl1,Pl2,RPl2,[ILi,ICo,TICa]).

% carré cas en bas à droite
helpJouerCoup([HPl1|TPl1],[C,P],Compt,CPlateau,[Li,Co,[HPl1|TCa]],[HPl1|TRPl1],Pl2,RPl2,[ILi,ICo,[HICa|TICa]]):-
    divmod(CPlateau,4,Q1,R1),
    divmod(C,4,Q2,R2),
    Q2 > 1,
    R2 > 1,
    Q1 > 1,
    R1 > 1,
    Compt2 is Compt -1,
    CPlateau2 is CPlateau + 1,
    HICa is CPlateau -1,
    helpJouerCoup(TPl1,[C,P],Compt2,CPlateau2,[Li,Co,TCa],TRPl1,Pl2,RPl2,[ILi,ICo,TICa]).

%autre cas
helpJouerCoup([HPl1|TPl1],[C,P],Compt,CPlateau,X1,[HPl1|TRPl1],Pl2,RPl2,X2):-
    Compt2 is Compt -1,
    CPlateau2 is CPlateau + 1,
    helpJouerCoup(TPl1,[C,P],Compt2,CPlateau2,X1,TRPl1,Pl2,RPl2,X2).

%le 2ieme argument doit être compris entre 0 et 3 (attention avec 0 pour le pavé (donc faire -1 pui mod 4 our le premier appel))
modifPiecesDispo([1|T],0,[0|T]).

modifPiecesDispo([0|[1|T]],0,[0|[0|T]]).

modifPiecesDispo([H|[H2|T]],Piece,[H|[H2|TRes]]):-
    X is Piece-1,
    modifPiecesDispo(T,X,TRes).



modifPlateau2(_,[],_).

modifPlateau2(Pl2,[[IX1,IX2,IX3,IX4]|T],RPl2):-
    is_set([IX1,IX2,IX3,IX4]), % is_set est vrai si il n'y a pas de doublons
    nth0(IX1,Pl2,X1),
    nth0(IX2,Pl2,X2),
    nth0(IX3,Pl2,X3),
    nth0(IX4,Pl2,X4),
    RX1 is X1 - 1,
    RX2 is X2 - 1,
    RX3 is X3 - 1,
    RX4 is X4 - 1,
    nth0(IX1,RPl2,RX1),
    nth0(IX2,RPl2,RX2),
    nth0(IX3,RPl2,RX3),
    nth0(IX4,RPl2,RX4),
    modifPlateau2(Pl2,T,RPl2).

modifPlateau2(Pl2,[[IX1,IX2,IX3,IX4]|T],RPl2):-
    not(is_set([IX1,IX2,IX3,IX4])),
    nth0(IX1,Pl2,X1),
    nth0(IX2,Pl2,X2),
    nth0(IX3,Pl2,X3),
    nth0(IX4,Pl2,X4),
    diffBloquerInutile([X1,X2,X3,X4],[RX1,RX2,RX3,RX4]),
    nth0(IX1,RPl2,RX1),
    nth0(IX2,RPl2,RX2),
    nth0(IX3,RPl2,RX3),
    nth0(IX4,RPl2,RX4),
    modifPlateau2(Pl2,T,RPl2).


%dans le plateau 2 , une valeur négative signifie que la case est utilisé par une pièce
% de 1 à 4 cela montre le nombre de coups liés à la case qui mène à la victoir
% supérieur à 10 signifie que la case est libre mais inutile (il y déja 2 pièces du même type sur la même ligne par example)
%cette fonction est appelé quand on sait que le quadruplet (ligne , colonne ou carré)
%contient des doublons( et donc 2 fois la même piéce (même couleur et même type))
%et permet des faires passer à 42 (valeur qui restera au dessus de 10 , même avec les -1 qu'il y a dans modifPlateau2)
% les cases libres mais inutile et de garder une valeur négative pour les cases occupés par un pion
diffBloquerInutile([],[]).

diffBloquerInutile([H|T],[H|RT]):-
    H<0,
    diffBloquerInutile(T,RT).

diffBloquerInutile([_|T],[RH|RT]):-
    RH is 42,
    diffBloquerInutile(T,RT).


%/////////////////////////////////// choix du coup /////////////////////////////////

%tout les fonctions ici sont à améliorer (ainsi que la représentation du deuxiéme plateau , il faut y mettre plus d'info)
%le but est pour l'instant d'avoir un projet fonctionnel , l'ia sera améliorer une fois que le projet marchera complétement

%pour la pièce

%on choisi en priorité une piéce qui est encore en double (choixPieceDispo1), et si il n'y plus de piéces en double on choisit n'importe laquelle (choixPieceDispo2)
%la liste des piéces (deuxième paramètre) est trié du plus prioritaire au moin prioritaire
choixPiecesDispo([0,0,0,0,0,0,0,0],[]).

choixPiecesDispo(PiecesDispo,[H|TPiecesChoisi]):-
    choixPieceDispo1(PiecesDispo,0,H,RPD),
    choixPiecesDispo(RPD,TPiecesChoisi).

choixPiecesDispo(PiecesDispo,[H|TPiecesChoisi]):-
    choixPieceDispo2(PiecesDispo,0,H,RPD),
    choixPiecesDispo(RPD,TPiecesChoisi).

%le premier paramètre est le tableau des pièces disponibles
%lors du premier appel à cette fonction , le deuxiéme paramètre vaut 0
% le troisième est la piecé retourné (0 pour le pavé)
%le quatrième est les piecès dispo avec la piéce choisit qui devient indisponible
choixPieceDispo1([1|[1|T]],Compt,Compt,[0|[1|T]]).

choixPieceDispo1([P1|[P2|T]],Compt,Piece,[P1|[P2|TR]]):-
    Compt2 is Compt +1 ,
    choixPieceDispo1(T,Compt2,Piece,TR).

%on part du principe que on modifie les pièces seuelement avec la fonction modifPiecesDispo fait précédemment.
%cela implique que si un type de pièce n'est pas en double , alors le tableau des pièces disponible représente ca avec un 0 puis un 1. (on suppose donc que l'inverse n'est pas possible)
choixPieceDispo2([0|[1|T]],Compt,Compt,[0|[0|T]]).

choixPieceDispo2([0|[0|T]],Compt,Piece,[0|[0|TR]]):-
    Compt2 is Compt +1 ,
    choixPieceDispo2(T,Compt2,Piece,TR).

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
    X > 10. % libre mais inutile
            % !!!!!!! attention c'est faux ce que j'ai fais avec inutile , c'est pas parceque il y un doublon en ligne que le reste des cases en ligne deviennet inutile. (elles peuvent toujorus gagner en colonne ou en carré)
            % je laisse ça comme pour le moment mais à changer rapidement

choixCases4([HPl2|TPl2],Compt,Case,[HPl2|TRPl2]):-
    Compt2 is Compt +1,
    choixCases4(TPl2,Compt2,Case,TRPl2).

%là on risque fortement de perdre mais bon au moin on perd en jouant (si on choisit pas une case c'est loose aussi)
choixCase5([2|TPl2],Compt,Compt,[-1|TPl2]).

choixCases5([HPl2|TPl2],Compt,Case,[HPl2|TRPl2]):-
    Compt2 is Compt +1,
    choixCases5(TPl2,Compt2,Case,TRPl2).

choixCases(Pl2,[]):-
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

% construction du coup

choixCoup(Pl1,Pl2,PiecesDispo,C,P):-
    choixPiecesDispo(PiecesDispo,PiecesChoisi),
    choixCases(Pl2,CasesChoisi),
    prioriteCasesSurPieces(Pl1,Pl2,PiecesDispo,PieceChoisi,CasesChoisi,PiecesChoisi,C,P).

%cette priotité est pour simplifier pour la première version de l'ia , en vrai quand il ne reste plus qu'une pièce pour un type , il vaut mieu privilégier la pièce parfois
prioriteCasesSurPieces(Pl1,Pl2,PiecesDispo,_,[HC|_],[HP|_],HC,HP):-
    jouerCoup(Pl1,[HC,HP],_,PiecesDispo,_,Pl2,_). % on vérifier qu'on peut jouer le coup

prioriteCasesSurPieces(Pl1,Pl2,PiecesDispo,PiecesChoisi,[HC|TC],[_|TP],C,P):-
    %not(jouerCoup(Pl1,[HC,HP],_,PiecesDispo,_,Pl2,_)),
    % pas besoin de l'appel à jouer au dessus , car on sait que on ne peut pas jouer l'appel a été fait au dessus
    prioriteCasesSurPieces(Pl1,Pl2,PiecesDispo,PiecesChoisi,[HC|TC],TP,C,P).

prioriteCasesSurPieces(Pl1,Pl2,PiecesDispo,PiecesChoisi,[_|TC],[],C,P):-
    prioriteCasesSurPieces(Pl1,Pl2,PiecesDispo,PiecesChoisi,TC,PiecesChoisi,C,P).
