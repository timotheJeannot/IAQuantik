import enums.Couleur;
import enums.TypeCoup;

import java.io.IOException;
import java.net.Socket;
import java.util.Arrays;

public class Mediator {

    public static void main(String... args) {
        AIEngine ai = null;
        DataStreamManager dsm = null;
        Socket socket = null;
        Couleur couleurJoueur;

        //Checking number of arguments
        if (args.length != 2) {
            System.err.println("Usage : 'hôte port '.");
            System.exit(-1);
        }

        //to do : Instanciation de AIEngine

        //Socket creation
        try {
            socket = new Socket(args[0], Integer.parseInt(args[1]));
        } catch (NumberFormatException nfe) {
            System.err.println("Erreur format port.");
            System.exit(-1);
        } catch (IOException ioe) {
            System.err.println("Erreur création socket.");
            System.err.println("=> " + ioe);
            System.exit(-1);
        }

        //Data stream manager creation
        try { dsm = new DataStreamManager(socket);
        }
        catch (DataStreamManagerException dsme) {
            System.err.println(dsme.getMessage());
            try { socket.close(); }
            catch (Exception ignored) {}
            finally { System.exit(-1); }
        }

        ai = new AIEngine();

        try {
            Coup lireCoup;
            couleurJoueur = dsm.lireCouleur();
            ai.co = couleurJoueur;
            TypeCoup typeCoup = TypeCoup.CONT;

            // Déroulement joueur blanc
            if (couleurJoueur.equals(Couleur.BLANC)) {

                //1ère partie
                System.out.println("Début première partie");
                do {
                    Coup c = ai.coupIA();
                    dsm.envoiCoup(c);
                    if(c.propriete == TypeCoup.CONT.getValue()) {
                        lireCoup = dsm.lireCoup();
                        typeCoup = TypeCoup.parse(lireCoup.propriete);
                        if (typeCoup == TypeCoup.CONT) {
                            ai.updatePlateau(lireCoup);
                        }
                    }
                    else {
                        typeCoup = TypeCoup.parse(c.propriete);
                    }
                }while(typeCoup == TypeCoup.CONT);

                //2ème partie
                System.out.println("Début deuxième partie");
                ai.remiseAZero();
                do {
                    lireCoup = dsm.lireCoup();
                    typeCoup = TypeCoup.parse(lireCoup.propriete);
                    if (typeCoup == TypeCoup.CONT) {
                        ai.updatePlateau(lireCoup);
                        Coup c = ai.coupIA();
                        dsm.envoiCoup(c);
                        typeCoup = TypeCoup.parse(c.propriete);
                    }
                }while(typeCoup == TypeCoup.CONT);

            }


            //Déroulement joueur noir
            else {

                //1ère partie
                System.out.println("Début première partie");
                do {
                    lireCoup = dsm.lireCoup();
                    typeCoup = TypeCoup.parse(lireCoup.propriete);
                    if (typeCoup == TypeCoup.CONT) {
                        ai.updatePlateau(lireCoup);
                        Coup c = ai.coupIA();
                        dsm.envoiCoup(c);
                        typeCoup = TypeCoup.parse(c.propriete);
                    }
                }while(typeCoup == TypeCoup.CONT);

                //2ème partie
                System.out.println("Début deuxième partie");
                ai.remiseAZero();
                do {
                    Coup c = ai.coupIA();
                    dsm.envoiCoup(c);
                    if(c.propriete == TypeCoup.CONT.getValue()) {
                        lireCoup = dsm.lireCoup();
                        typeCoup = TypeCoup.parse(lireCoup.propriete);
                        if (typeCoup == TypeCoup.CONT) {
                            ai.updatePlateau(lireCoup);
                        }
                    }
                    else {
                        typeCoup = TypeCoup.parse(c.propriete);
                    }
                }while(typeCoup == TypeCoup.CONT);
            }

        } catch (Exception e) {
            System.err.println(e.getMessage());
        }
        finally {
            try { socket.close(); }
            catch (Exception e) {
                System.err.println("Erreur fermeture socket.");
                System.err.println("=> " + e);
            }
        }
    }

}