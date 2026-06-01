package vn.edu.fpt.enums;

public enum CouponStatus {
    ACTIVE("active"), INACTIVE("inactive");

    private final String value;
    CouponStatus(String value) { this.value = value; }
    public String getValue() { return value; }
    public static CouponStatus fromValue(String value) {
        for (CouponStatus s : values()) if (s.value.equals(value)) return s;
        throw new IllegalArgumentException("Unknown CouponStatus: " + value);
    }
}
