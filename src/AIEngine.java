import enums.Couleur;
import org.jpl7.*;

import java.util.Arrays;
import java.util.Map;

import static org.jpl7.Util.*;

public class AIEngine {
    String file = "/home/antoine/Téléchargements/IAQuantik/src/IA.pl";
    Query q1;
    Couleur co;
    int[] tab = new int[16];
    int[] tab2 = new int[16];
    int[] tab3 = new int[8];
    int[] tab4 = new int[8];

    public AIEngine() {
        System.out.println(file.toString());
        q1 = new Query("consult", new Term[] {new Atom(file)});
        System.out.println( "consult " + (q1.hasSolution() ? "succeeded" : "failed"));
        for (int i = 0; i <16 ; i++) {
            if(i<8) {
                tab3[i]=1;
                tab4[i]=1;
            }
            tab[i]=0;
            tab2[i]=4;
        }
    }
    //choixCoupEtJoue(Pl1,Pl2,PiecesDispo,C,P,RPl1,RPl2):- noir = 1


    public Coup coupIA() {

        System.out.println("Test 1 AI");
        Term A = intArrayToList(tab);
        Term B = intArrayToList(tab2);
        Term C = intArrayToList(tab3);
        System.out.println("tab = "+ Arrays.toString(tab));
        System.out.println("tab2 = "+ Arrays.toString(tab2));
        System.out.println("tab3 = "+ Arrays.toString(tab3));
        System.out.println("Test 2 AI");
        Variable D = new Variable("D");
        Variable E = new Variable("E");
        Variable F = new Variable("F");
        Variable G = new Variable("G");
        Variable H = new Variable("H");
        org.jpl7.Integer I = new org.jpl7.Integer(co.getValue());
        System.out.println("Test 3 AI");
        q1 = new Query("choixCoupEtJoue", new Term[] {A, B, C, D, E, F, G, H, I});
        System.out.println("Test 3.5 AI");
        Map<String, Term> solution= q1.oneSolution();
        System.out.println("Test 3.6 AI");
        int caseJ = solution.get("D").intValue();
        System.out.println("Test 3.7 AI");
        int pion = solution.get("E").intValue();
        System.out.println("Test 3.8 AI");
        Term[] plateau1 = listToTermArray(solution.get("F"));
        System.out.println("Test 3.9 AI");
        Term[] plateau2 = listToTermArray(solution.get("G"));
        System.out.println("Test 4 AI");

        tab3[pion] = 1;
        for (int i = 0; i < 16; i++) {
            tab[i] = plateau1[i].intValue();
            tab2[i] = plateau2[i].intValue();
        }

        System.out.println("D = "+caseJ);
        System.out.println("E = "+pion);
       // System.out.println(q1.hasSolution() ? "provable" : "not provable");

        tab3[pion] = 0;
        int ligne = caseJ/4;
        int colonne = caseJ%4;

        if (pion == 0 || pion  == 1) {
            pion = 1;
        }
        if (pion == 2 || pion  == 3) {
            pion = 0;
        }
        if (pion == 4 || pion  == 5) {
            pion = 2;
        }
        if (pion == 6 || pion  == 7) {
            pion = 3;
        }

        System.out.println("Test 5 AI");
        return new Coup(ligne, colonne, pion);
    }

    //choixCoupEtJoue(Pl1,Pl2,PiecesDispo,C,P,RPl1,RPl2):-
    public void updatePlateau(Coup c) {
        Term A = intArrayToList(tab);
        Term B = intArrayToList(tab2);
        Term C = intArrayToList(tab4);
        org.jpl7.Integer D = new org.jpl7.Integer(c.colonne+c.ligne*4);
        org.jpl7.Integer E = new org.jpl7.Integer(pionEToPionP(c.pion)); //à modifier pour prendre en compte la couleur
        Variable F = new Variable("F");
        Variable G = new Variable("G");
        Variable H = new Variable("H");
        org.jpl7.Integer I = new org.jpl7.Integer((co.getValue()==0) ? 1 : 0);
        System.out.println("Test A = "+A.toString());
        System.out.println("Test B = "+B.toString());
        System.out.println("Test C = "+C.toString());
        System.out.println("Test D = "+D.intValue());
        System.out.println("Test E = "+E.intValue());

        q1 = new Query("choixCoupEtJoue", new Term[] {A, B, C, D, E, F, G, H, I});
        System.out.println(q1.hasSolution() ? "provable" : "not provable");
        Map<String, Term> solution= q1.oneSolution();
        Term[] plateau1 = listToTermArray(solution.get("F"));
        Term[] plateau2 = listToTermArray(solution.get("G"));

        tab4[E.intValue()] = 0;
        for (int i = 0; i < 16; i++) {
            tab[i] = plateau1[i].intValue();
            tab2[i] = plateau2[i].intValue();
        }

        System.out.println("Test4");
        System.out.println("tab = "+ Arrays.toString(tab));
        System.out.println("tab2 = "+ Arrays.toString(tab2));

    }

    public int pionEToPionP(int pion) {
        if (pion == 0 ) {
            return (tab4[2] == 1 ? 2 : 3);
        }
        if (pion == 1) {
            return (tab4[0] == 1 ? 1 : 0);
        }
        if (pion == 2) {
            return (tab4[4] == 1 ? 4 : 5);
        }
        if (pion == 3) {
            return (tab4[6] == 1 ? 6 : 7);
        }
        return 0;
    }

    public int pionPtoPionE(int pion, Couleur c) {
        return 0;
    }

}
