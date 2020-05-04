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

    public TypeCoup lireCoup() {
        try {

            int typeCoup = is.readInt();

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

            }
            return TypeCoup.parse(typeCoup);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

}
