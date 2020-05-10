import enums.Bloque;
import enums.Couleur;
import enums.TypeCoup;
import org.jpl7.*;

import java.util.Arrays;
import java.util.Map;

import static org.jpl7.Util.*;

public class AIEngine {
    String file = "../IA.pl";
    Query q1;
    Couleur co;
    int[] plateau1 = new int[16];
    int[] plateau2 = new int[16];
    int[] piecesDispos = new int[8];
    int[] piecesDisposAdv = new int[8];

    public AIEngine() {
        System.out.println(file.toString());
        q1 = new Query("consult", new Term[] {new Atom(file)});
        System.out.println( "consult " + (q1.hasSolution() ? "succeeded" : "failed"));
        for (int i = 0; i <16 ; i++) {
            if(i<8) {
                piecesDispos[i]=1;
                piecesDisposAdv[i]=1;
            }
            plateau1[i]=0;
            plateau2[i]=4;
        }
    }
    //choixCoupEtJoue(Pl1,Pl2,PiecesDispo,C,P,RPl1,RPl2):- noir = 1


    public Coup coupIA() {

        int propriete = TypeCoup.CONT.getValue();
        int bloque = Bloque.NONBLOQUE.getValue();
        Term A = intArrayToList(plateau1);
        Term B = intArrayToList(plateau2);
        Term C = intArrayToList(piecesDispos);
        Variable D = new Variable("D");
        Variable E = new Variable("E");
        Variable F = new Variable("F");
        Variable G = new Variable("G");
        Variable H = new Variable("H");
        org.jpl7.Integer I = new org.jpl7.Integer(co.getValue());
        q1 = new Query("choixCoupEtJoue", new Term[] {A, B, C, D, E, F, G, H, I});


        if (q1.hasSolution()) {
            Map<String, Term> solution = q1.oneSolution();
            int caseJ = solution.get("D").intValue();
            int pion = solution.get("E").intValue();
            Term[] plateau1 = listToTermArray(solution.get("F"));
            Term[] plateau2 = listToTermArray(solution.get("G"));
            Term[] piecesDispos = listToTermArray(solution.get("H"));
            for (int i = 0; i < 16; i++) {
                if (i < 8) {
                    this.piecesDispos[i] = piecesDispos[i].intValue();
                }
                this.plateau1[i] = plateau1[i].intValue();
                this.plateau2[i] = plateau2[i].intValue();
            }

            int ligne = caseJ / 4;
            int colonne = caseJ % 4;

            if (pion == 1 || pion == 5) {
                pion = 1;
            }
            if (pion == 2 || pion == 6) {
                pion = 0;
            }
            if (pion == 3 || pion == 7) {
                pion = 2;
            }
            if (pion == 4 || pion == 8) {
                pion = 3;
            }


            Term J = intArrayToList(this.plateau1);
            q1 = new Query("gagne", new Term[] {J});
            System.out.println(q1.hasSolution() ? "Gagné" : "");
            if (q1.hasSolution()) {
                propriete = 1;
            }
            return new Coup(bloque,ligne, colonne, pion, propriete);
        }
        System.out.println("Bloqué");
        return new Coup(1,0, 0, 0, 3);
    }

    public void updatePlateau(Coup c) {
        Term A = intArrayToList(plateau1);
        Term B = intArrayToList(plateau2);
        Term C = intArrayToList(piecesDisposAdv);
        org.jpl7.Integer D = new org.jpl7.Integer(c.colonne+c.ligne*4);
        org.jpl7.Integer E = new org.jpl7.Integer(pionEToPionP(c.pion, (co.getValue()==0) ? 1 : 0));
        Variable F = new Variable("F");
        Variable G = new Variable("G");
        Variable H = new Variable("H");
        org.jpl7.Integer I = new org.jpl7.Integer((co.getValue()==0) ? 1 : 0);

        q1 = new Query("choixCoupEtJoue", new Term[] {A, B, C, D, E, F, G, H, I});
        //System.out.println(q1.hasSolution() ? "provable" : "not provable");
        Map<String, Term> solution= q1.oneSolution();
        Term[] plateau1 = listToTermArray(solution.get("F"));
        Term[] plateau2 = listToTermArray(solution.get("G"));
        Term[] piecesDispos = listToTermArray(solution.get("H"));

        for (int i = 0; i < 16; i++) {
            if (i<8) {
                piecesDisposAdv[i] = piecesDispos[i].intValue();
            }
            this.plateau1[i] = plateau1[i].intValue();
            this.plateau2[i] = plateau2[i].intValue();
        }

    }

    public int pionEToPionP(int pion, int couleur) {
        int valPion = 0;
        if (couleur == 1) {
            valPion += 4;
        }
        if (pion == 0 ) {
            return (valPion+2);
        }
        if (pion == 1) {
            return (valPion+1);
        }
        if (pion == 2) {
            return (valPion+3);
        }
        if (pion == 3) {
            return (valPion+4);
        }
        return 0;
    }

    public void remiseAZero() {
        for (int i = 0; i <16 ; i++) {
            if(i<8) {
                piecesDispos[i]=1;
                piecesDisposAdv[i]=1;
            }
            plateau1[i]=0;
            plateau2[i]=4;
        }
    }

}