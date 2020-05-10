package enums;

public enum Couleur {

    BLANC(0),
    NOIR(1);

    private final int value;
    Couleur(int value) { this.value = value; }
    public int getValue() { return value; }

    @Override
    public String toString() {
        return String.valueOf(this.value);
    }

    public static Couleur parse(int i) {
        return (i == 0) ? Couleur.BLANC : Couleur.NOIR;
    }
}
