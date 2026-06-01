package vn.edu.fpt.enums;

public enum CategoryStatus {
    ACTIVE("active"), INACTIVE("inactive");

    private final String value;
    CategoryStatus(String value) { this.value = value; }
    public String getValue() { return value; }
    public static CategoryStatus fromValue(String value) {
        for (CategoryStatus s : values()) if (s.value.equals(value)) return s;
        throw new IllegalArgumentException("Unknown CategoryStatus: " + value);
    }
}
