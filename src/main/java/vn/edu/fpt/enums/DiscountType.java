package vn.edu.fpt.enums;

public enum DiscountType {
    PERCENT("percent"), FIXED("fixed");

    private final String value;
    DiscountType(String value) { this.value = value; }
    public String getValue() { return value; }
    public static DiscountType fromValue(String value) {
        for (DiscountType s : values()) if (s.value.equals(value)) return s;
        throw new IllegalArgumentException("Unknown DiscountType: " + value);
    }
}
