import enums.Couleur;
import org.jpl7.*;

import java.util.Arrays;
import java.util.Map;

import static org.jpl7.Util.*;

public class AIEngine {
    String file = "../IA.pl";
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

        int propriete = 0;
        int bloque = 0;
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
        System.out.println(q1.hasSolution() ? "provable" : "not provable");

        if (q1.hasSolution()) {
            Map<String, Term> solution = q1.oneSolution();
            int caseJ = solution.get("D").intValue();
            int pion = solution.get("E").intValue();
            Term[] plateau1 = listToTermArray(solution.get("F"));
            Term[] plateau2 = listToTermArray(solution.get("G"));
            Term[] piecesDispos = listToTermArray(solution.get("H"));
            for (int i = 0; i < 16; i++) {
                if (i < 8) {
                    tab3[i] = piecesDispos[i].intValue();
                }
                tab[i] = plateau1[i].intValue();
                tab2[i] = plateau2[i].intValue();
            }


            System.out.println("D = " + caseJ);
            System.out.println("E = " + pion);
            // System.out.println(q1.hasSolution() ? "provable" : "not provable");

            //updatePiecesDispos(pion);
            int ligne = caseJ / 4;
            int colonne = caseJ % 4;
            System.out.println("tab = "+ Arrays.toString(tab));
            System.out.println("tab2 = "+ Arrays.toString(tab2));
            System.out.println("tab3 = "+ Arrays.toString(tab3));

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

            Term J = intArrayToList(tab);
            System.out.println("tab = "+ Arrays.toString(tab));
            q1 = new Query("gagne", new Term[] {J});
            System.out.println(q1.hasSolution() ? "Gagné" : "Pas gagné");
            if (q1.hasSolution()) {
                propriete = 1;
            }
            System.out.println("Test 5 AI");
            return new Coup(bloque,ligne, colonne, pion, propriete);
        }
        System.out.println("Bloqué");
        return new Coup(1,0, 0, 0, 3);
    }

    //choixCoupEtJoue(Pl1,Pl2,PiecesDispo,C,P,RPl1,RPl2):-
    public void updatePlateau(Coup c) {
        Term A = intArrayToList(tab);
        Term B = intArrayToList(tab2);
        Term C = intArrayToList(tab4);
        System.out.println("Colonne : "+c.colonne+" Ligne : "+c.ligne);
        org.jpl7.Integer D = new org.jpl7.Integer(c.colonne+c.ligne*4);
        org.jpl7.Integer E = new org.jpl7.Integer(pionEToPionP(c.pion, (co.getValue()==0) ? 1 : 0));
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
        Term[] piecesDispos = listToTermArray(solution.get("H"));

        for (int i = 0; i < 16; i++) {
            if (i<8) {
                tab4[i] = piecesDispos[i].intValue();
            }
            tab[i] = plateau1[i].intValue();
            tab2[i] = plateau2[i].intValue();
        }

        System.out.println("Test4");
        System.out.println("tab = "+ Arrays.toString(tab));
        System.out.println("tab2 = "+ Arrays.toString(tab2));
        System.out.println("tab4 = "+ Arrays.toString(tab4));

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

    public void updatePiecesDispos(int pion) {
        switch (pion) {
            case 0 :
                if (tab3[2] == 0) {
                    tab3[3] = 0;
                }
                else if (tab3[2] == 1) {
                    tab3[2] = 0;
                }
                break;
            case 1 :
                if (tab3[0] == 0) {
                    tab3[1] = 0;
                }
                else if (tab3[0] == 1)  {
                    tab3[0] = 0;
                }
                break;
            case 2 :
                if (tab3[4] == 0) {
                    tab3[5] = 0;
                }
                else if (tab3[4] == 1)  {
                    tab3[4] = 0;
                }
                break;
            case 3 :
                if (tab3[6] == 0) {
                    tab3[7] = 0;
                }
                else if (tab3[6] == 1) {
                    tab3[6] = 0;
                }
                break;

        }
    }


    public int pionPtoPionE(int pion, Couleur c) {
        return 0;
    }

    public void remiseAZero() {
        for (int i = 0; i <16 ; i++) {
            if(i<8) {
                tab3[i]=1;
                tab4[i]=1;
            }
            tab[i]=0;
            tab2[i]=4;
        }
    }

}