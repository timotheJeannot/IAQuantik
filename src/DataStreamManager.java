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

            if(TypeCoup.parse(typeCoup).equals(TypeCoup.CONT)) {

                Bloque estBloque = is.readInt() == Bloque.NONBLOQUE.getValue() ?
                        Bloque.NONBLOQUE : Bloque.BLOQUE;
                int pion = is.readInt();
                int ligne = is.readInt();
                int colonne = is.readInt();

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
        int bloque = c.bloque;
        int pion = c.pion;
        int ligne = c.ligne;
        int colonne = c.colonne;
        int type = c.propriete;


        try {
            os.writeInt(bloque);
            os.writeInt(pion);
            os.writeInt(ligne);
            os.writeInt(colonne);
            os.writeInt(type);
            os.flush();

        } catch (IOException e) {
            e.printStackTrace();
        }

    }

}