package enums;

public enum Bloque {

    NONBLOQUE(0),
    BLOQUE(1);

    private final int value;
    Bloque(int value) { this.value = value; }
    public int getValue() { return value; }

    @Override
    public String toString() {
        return String.valueOf(this.value);
    }

    public static Bloque parse(int i) {
        return (i == 0) ? Bloque.NONBLOQUE : Bloque.BLOQUE;
    }
}
