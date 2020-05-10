package enums;


public enum Ligne {

    UN(0),
    DEUX(1),
    TROIS(2),
    QUATRE(3);

    private final int value;
    Ligne(int value) { this.value = value; }
    public int getValue() { return value; }

    public static Ligne parse(int i) {
        switch (i) {
            case 0 : return Ligne.UN;
            case 1 : return Ligne.DEUX;
            case 2 : return Ligne.TROIS;
            case 3 : return Ligne.QUATRE;
            default : return null;
        }
    }

}