package enums;

public enum Colonne {
    A(0),
    B(1),
    C(2),
    D(3);

    private final int value;
    Colonne(int value) { this.value = value; }
    public int getValue() { return this.value; }

    public static Colonne parse(int i) {
        switch (i) {
            case 0 : return Colonne.A;
            case 1 : return Colonne.B;
            case 2 : return Colonne.C;
            case 3 : return Colonne.D;
            default : return null;
        }
    }
}
