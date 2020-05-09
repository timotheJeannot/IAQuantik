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
        Couleur couleurAdversaire;
        boolean stop = false;

        //Checking number of arguments
        if (args.length != 3) {
            System.err.println("Usage : 'hôte port ia_prolog'.");
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
            System.out.println("Reçu couleur : "+couleurJoueur.name());
            TypeCoup typeCoup = TypeCoup.CONT;
            if (couleurJoueur.equals(Couleur.BLANC)) {
                couleurAdversaire = Couleur.NOIR;

                //1ère partie
                System.out.println("Début première partie");
                do {
                    Coup c = ai.coupIA();
                    //to do : Calcul du prochain coup + envoi du coup au joueur
                    dsm.envoiCoup(c);
                    lireCoup = dsm.lireCoup();
                    ai.updatePlateau(lireCoup);
                    typeCoup = TypeCoup.parse(lireCoup.propriete);
                    //to do : Envoi du coup à l'AIEngine
                }while(typeCoup == TypeCoup.CONT);

                //2ème partie
                System.out.println("Début deuxième partie");
                do {
                    lireCoup = dsm.lireCoup();
                    ai.updatePlateau(lireCoup);
                    typeCoup = TypeCoup.parse(lireCoup.propriete);
                    //to do : Envoi du coup à l'AIEngine + calcul du prochain coup
                    //to do : Envoi du coup au joueur
                    Coup c = ai.coupIA();
                    dsm.envoiCoup(c);
                }while(typeCoup == TypeCoup.CONT);

            }


            else {
                couleurAdversaire = Couleur.BLANC;

                //1ère partie
                System.out.println("Début première partie");
                do {
                    lireCoup = dsm.lireCoup();
                    ai.updatePlateau(lireCoup);
                    System.out.println("Test 1 Med ");
                    typeCoup = TypeCoup.parse(lireCoup.propriete);
                    System.out.println("Test 2 Med ");
                    //to do : Envoi du coup à l'AIEngine + calcul du prochain coup
                    //to do : Envoi du coup au joueur
                    Coup c = ai.coupIA();
                    dsm.envoiCoup(c);
                }while(typeCoup == TypeCoup.CONT);

                //2ème partie
                System.out.println("Début deuxième partie");
                do {
                    //to do : Calcul du prochain coup + envoi du coup au joueur
                    Coup c = ai.coupIA();
                    dsm.envoiCoup(c);
                    lireCoup = dsm.lireCoup();
                    ai.updatePlateau(lireCoup);
                    typeCoup = TypeCoup.parse(lireCoup.propriete);
                    //to do : Envoi du coup à l'AIEngine
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
