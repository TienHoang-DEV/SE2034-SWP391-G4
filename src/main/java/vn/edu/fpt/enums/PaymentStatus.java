package vn.edu.fpt.enums;

public enum PaymentStatus {
    PENDING("pending"), SUCCESS("success"), FAILED("failed");

    private final String value;
    PaymentStatus(String value) { this.value = value; }
    public String getValue() { return value; }
    public static PaymentStatus fromValue(String value) {
        for (PaymentStatus s : values()) if (s.value.equals(value)) return s;
        throw new IllegalArgumentException("Unknown PaymentStatus: " + value);
    }
}
