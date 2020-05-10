public class Coup {

    int bloque;
    int propriete;
    int ligne;
    int colonne;
    int pion;

    public Coup(int ligne, int colonne, int pion) {
        this.ligne = ligne;
        this.colonne = colonne;
        this.pion = pion;
        this.propriete = 0;
        this.bloque = 0;
    }
    public Coup(int bloque, int ligne, int colonne, int pion, int propriete) {
        this.bloque = bloque;
        this.ligne = ligne;
        this.colonne = colonne;
        this.pion = pion;
        this.propriete = propriete;
    }


}