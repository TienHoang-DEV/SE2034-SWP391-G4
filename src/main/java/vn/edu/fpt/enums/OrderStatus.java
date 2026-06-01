package vn.edu.fpt.enums;

public enum OrderStatus {
    PENDING("pending"), PAID("paid"), COMPLETED("completed"), CANCELLED("cancelled"), EXPIRED("expired");

    private final String value;
    OrderStatus(String value) { this.value = value; }
    public String getValue() { return value; }
    public static OrderStatus fromValue(String value) {
        for (OrderStatus s : values()) if (s.value.equals(value)) return s;
        throw new IllegalArgumentException("Unknown OrderStatus: " + value);
    }
}
