package enums;

public enum TypeCoup {

    CONT(0),
    GAGNE(1),
    NUL(2),
    PERDU(3);

    private final int value;
    TypeCoup(int value) { this.value = value; }
    public int getValue() { return value; }

    @Override
    public String toString() {
        return String.valueOf(this.value);
    }


    public static TypeCoup parse(int i) {
        switch (i) {
            case 0 : return TypeCoup.CONT;
            case 1 : return TypeCoup.GAGNE;
            case 2 : return TypeCoup.NUL;
            case 3 : return TypeCoup.PERDU;
            default : return null;
        }
    }
}
