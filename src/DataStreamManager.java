import enums.*;

import java.io.*;
import java.net.Socket;

public class DataStreamManager implements Closeable {

    private DataInputStream is;
    private DataOutputStream os;

    public DataStreamManager(Socket sock) throws DataStreamManagerException {
        try { this.is = new DataInputStream(sock.getInputStream()); }
        catch (IOException e) { throw new DataStreamManagerException("Erreur récupération 'InputStream'"); }
        try { this.os = new DataOutputStream(sock.getOutputStream()); }
        catch (IOException e) { throw new DataStreamManagerException("Erreur récupération 'OutputStream'"); }
    }

    @Override
    public void close() {
        try { this.is.close(); }
        catch (Exception ignored) {}
        finally {
            try { this.os.close(); }
            catch (Exception ignored) {}
        }
    }


    public Couleur lireCouleur() {
        try {
            return (is.readInt() == Couleur.BLANC.getValue()) ?
                    Couleur.BLANC : Couleur.NOIR;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Coup lireCoup() {
        try {

            int typeCoup = is.readInt();
            System.out.println("typecoup " + typeCoup);

            if(TypeCoup.parse(typeCoup).equals(TypeCoup.CONT)) {

                Bloque estBloque = is.readInt() == Bloque.NONBLOQUE.getValue() ?
                        Bloque.NONBLOQUE : Bloque.BLOQUE;
                int couleur = is.readInt();
                int pion = is.readInt();
                int ligne = is.readInt();
                int colonne = is.readInt();

                System.out.println("Le joueur " + estBloque.name());
                System.out.println("pion = " + Pion.parse(pion).name());
                System.out.println("couleur = " + Couleur.parse(couleur).name());
                System.out.println("ligne = " + Ligne.parse(ligne).name());
                System.out.println("colonne = " + Colonne.parse(colonne).name());
                System.out.println("typeCoup = " + typeCoup);
                return new Coup(ligne, colonne, pion);
            }

            else {
                return new Coup(0,0,0,0,typeCoup);

            }

        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void envoiCoup(Coup c) {
        int bloqueAlea = c.bloque;
        int pionAlea = c.pion;
        int ligneAlea = c.ligne;
        int colonneAlea = c.colonne;
        int typeAlea = c.propriete;

        System.out.println("Envoi à joueur pion = " + Pion.parse(pionAlea).name());
        System.out.println("Envoi à joueur ligne = " + Ligne.parse(ligneAlea).name());
        System.out.println("Envoi à joueur colonne = " + Colonne.parse(colonneAlea).name());

        try {
            os.writeInt(bloqueAlea);
            os.writeInt(pionAlea);
            os.writeInt(ligneAlea);
            os.writeInt(colonneAlea);
            os.writeInt(typeAlea);
            os.flush();

        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    public void envoiCoup2() {
        int bloqueAlea = Bloque.NONBLOQUE.getValue();
        int pionAlea = (int)(Math.random() * 4);
        int ligneAlea = (int)(Math.random() * 4);
        int colonneAlea = (int)(Math.random() * 4);
        int typeAlea = TypeCoup.CONT.getValue();

        /*System.out.println("Envoi à joueur pion = " + Pion.parse(pionAlea).name());
        System.out.println("Envoi à joueur ligne = " + Ligne.parse(ligneAlea).name());
        System.out.println("Envoi à joueur colonne = " + Colonne.parse(colonneAlea).name());*/

        try {
            os.writeInt(bloqueAlea);
            os.writeInt(pionAlea);
            os.writeInt(ligneAlea);
            os.writeInt(colonneAlea);
            os.writeInt(typeAlea);
            os.flush();

        } catch (IOException e) {
            e.printStackTrace();
        }

    }

}