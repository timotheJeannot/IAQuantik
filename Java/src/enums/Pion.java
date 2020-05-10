package enums;

public enum Pion {

    CYLINDRE(0),
    PAVE(1),
    SPHERE(2),
    TETRAEDRE(3);

    private final int value;
    Pion(int value) { this.value = value; }
    public int getValue() { return value; }

    public static Pion parse(int i) {
        switch (i) {
            case 0 : return Pion.CYLINDRE;
            case 1 : return Pion.PAVE;
            case 2 : return Pion.SPHERE;
            case 3 : return Pion.TETRAEDRE;
            default : return null;
        }
    }
}
